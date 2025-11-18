# Setup

## Prerequisites

```sh
apt-get install docker-ce docker-compose-plugin
pip install -r requirements.txt
```

## Usage

1. Start 2 PostgreSQL instances, e.g. with Docker

    ```sh
    docker compose up -d
    ```

2. Get PostgreSQL ports from Docker

    ```sh
    docker compose port postgresql-migrated 5432
    docker compose port postgresql-installed 5432
    ```

3. Copy `defaults.ini` to `local.ini` and edit it to set the correct
   values. If you used the provided `docker-compose.yml`, you only need to
   change the port numbers.

4. Run the diff tool

    ```sh
    python compare-db-migrations.py --config local.ini
    ```

## Updating migration-base-schema.sql

When cleaning up the alembic revisions in xivo-manage-db, the base schema
needs to be updated accordingly to match the new base revision (the
revisions are applied on top of migration-base-schema.sql, which should
match the baseline schema expected by the alembic revisions).

To produce that baseline, the xivo-manage-db Dockerfile can be used.
Assuming the new baseline release is 25.14:

1. In the xivo-manage-db repository;
   checkout the git tag of the release corresponding to the new baseline
   revision;

   ```sh
   cd $LOCAL_GIT_REPOS/xivo-manage-db
   git checkout tags/wazo-25.14
   ```

2. Update the `requirements.txt` file to use the matching version of wazo
   dependencies;

    ```sh
    sed -i 's/master\.zip/wazo-25.14\.zip/' requirements.txt
    ```

3. Build the database image;
   first build `wazoplatform/wazo-base-db` image from
   `contribs/docker/wazo-base-db/Dockerfile`;
   then build the image for a fully initialized database using
   `Dockerfile`:

   ```sh
   docker build --no-cache -t wazoplatform/wazo-base-db:latest \
     -f contribs/docker/wazo-base-db/Dockerfile \
     contribs/docker/wazo-base-db
   docker build --no-cache -f Dockerfile -t xivo-manage-db:wazo-25.14 .
   ```

4. Deploy the container image:

   ```sh
   docker run -d --name xivo-manage-db-25.14 xivo-manage-db:wazo-25.14
   ```

5. Use pg_dump to dump the baseline schema as a sql file:

   ```sh
   docker exec -it xivo-manage-db-25.14 \
   pg_dump -U postgres -d asterisk \
   --exclude-table=alembic_version \
   --insert \
   > baseline-25.14.sql
   ```

6. Make sure the baseline dump uses unix instead of DOS line endings
   (i.e. no carriage return characters):

    ```sh
    dos2unix baseline-25.14.sql
    ```

    or

    ```sh
    sed -i 's/\r$//' baseline-25.14.sql
    ```

7. Copy the generated baseline schema dump to the wazo-tools/compare-db
   repository as the new migration-base-schema.sql, verify and commit the
   changes:

   ```sh
   cd $LOCAL_GIT_REPOS/wazo-tools/compare-db
   cp $LOCAL_GIT_REPOS/xivo-manage-db/baseline-25.14.sql migration-base-schema.sql
   git diff migration-base-schema.sql
   git commit -m "compare-db: raw baseline schema dump for wazo-25.14"
   ```

8. Run the compare-db-migrations.py tool(see [Usage](#usage))
9. Investigate each reported mismatches;
    common issues are changes in normalized representation of
    constraints;
   The migration-base-schema.sql file may need to be manually updated to
   address some mismatches;
   commit each fix;
10. When the compare-db-migrations.py tool reports no differences, a PR
    can be created, and a xivo-manage-db PR can use that PR as a
    `Depends-on` to validate the CI job.
