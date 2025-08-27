#!/usr/bin/env bash
# This script is used to generate a SQL schema dump 
# from a build of the Dockerfile-db of a project

set -euo pipefail
CONTAINER_ID=""
IMAGE_ID=""

# Default values

# Function to print output to stderr
print_status() {
    echo "[INFO] $1" >&2
}

print_success() {
    echo "[SUCCESS] $1" >&2
}

print_error() {
    echo "[ERROR] $1" >&2
}

# Function to show usage
show_usage() {
    cat << EOF
Usage: $0 [OPTIONS] [OUTPUT_FILE]

Generate a SQL schema dump from a build of the Dockerfile-db in this project.
current directory must be the root of the project.

OPTIONS:
    -h, --help          Show this help message
    -t, --timeout SEC   Wait timeout for database to be ready (default: 30)
    -f, --dockerfile    Path to Dockerfile-db (default: contribs/docker/Dockerfile-db)
    -u, --username      Username to use for database (default: project name)
    -d, --database      Database to use (default: project name)
    -a, --alembic-version-table    Alembic version table name (default: resolved from alembic env.py file)

OUTPUT_FILE:
    Output file path for the schema dump (default: stdout)

EXAMPLES:
    $0                                    # Generate dump to stdout
    $0 my_schema.sql                     # Generate dump to specific file
    $0 -t 60 my_schema.sql               # Wait 60 seconds for database to be ready

EOF
}


function get_alembic_version_table() {
    env_file=$(git ls-files | grep -E 'alembic/env.py$')
    table_name=$(sed -nr "s/VERSION_TABLE = (.*)/\1/p" $env_file | tr -d "'\"" | head -n1)
    if [[ -z "$table_name" ]]; then
        print_error "No alembic version table found from env.py file"
    fi
    echo "$table_name"
}


# Function to parse command line arguments
parse_arguments() {
    local project_name="$(basename $PWD)"
    local timeout=30
    local output_file=""
    local dockerfile=""
    local username="$project_name"
    local database="$project_name"
    local alembic_version_table="$(get_alembic_version_table)"
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            -t|--timeout)
                timeout="$2"
                shift 2
                ;;
            -f|--dockerfile)
                dockerfile="$2"
                shift 2
                ;;
            -u|--username)
                username="$2"
                shift 2
                ;;
            -d|--database)
                database="$2"
                shift 2
                ;;
            -a|--alembic-version-table)
                alembic_version_table="$2"
                shift 2
                ;;
            --)
                shift
                ;;
            -*)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
            *)
                if [[ -z "$output_file" ]]; then
                    output_file="$1"
                else
                    print_error "Multiple output files specified: $1"
                    exit 1
                fi
                shift
                ;;
        esac
    done


    # Return values via global variables
    TIMEOUT="$timeout"
    OUTPUT_FILE="$output_file"
    USERNAME="$username"
    DATABASE="$database"
    ALEMBIC_VERSION_TABLE="$alembic_version_table"
    if [[ -z "$ALEMBIC_VERSION_TABLE" ]]; then
        print_error "alembic version table name not specified"
        exit 1
    fi
    PROJECT_ROOT="$PWD"

    if [[ -n "$dockerfile" ]]; then
        DOCKERFILE_PATH="$dockerfile"
    else
        DOCKERFILE_PATH="$PROJECT_ROOT/contribs/docker/Dockerfile-db"
    fi

    print_status "Using project root: $PROJECT_ROOT"
    print_status "Using username: $USERNAME"
    print_status "Using database: $DATABASE"
    print_status "Using dockerfile: $DOCKERFILE_PATH"
    print_status "Using timeout: $TIMEOUT"
    print_status "Using output file: $OUTPUT_FILE"
    print_status "Using alembic version table: $ALEMBIC_VERSION_TABLE"
}

# Function to build the Docker image
build_image() {
    print_status "Building Docker image..."
    
    if [[ ! -f "$DOCKERFILE_PATH" ]]; then
        print_error "Dockerfile not found: $DOCKERFILE_PATH"
        print_error "Make sure the path of the dockerfile is correct relative to the working directory"
        exit 1
    fi
    
    # Build with -q flag to get image ID, redirect build output to stderr
    IMAGE_ID=$(docker build -q -f "$DOCKERFILE_PATH" $PROJECT_ROOT)
    
    if [[ $? -ne 0 ]] || [[ -z "$IMAGE_ID" ]]; then
        print_error "Docker build failed"
        exit 1
    fi
    
    print_success "Docker image built successfully: $IMAGE_ID"
}

# Function to check output directory and file permissions
check_output_permissions() {
    if [[ -n "$OUTPUT_FILE" ]]; then
        local output_dir=$(dirname "$OUTPUT_FILE")
        if [[ "$output_dir" != "." ]] && [[ ! -d "$output_dir" ]]; then
            print_error "Output directory does not exist: $output_dir"
            exit 1
        fi

        if [[ ! -w "$output_dir" ]]; then
            print_error "Output directory is not writable: $output_dir"
            exit 1
        fi
    fi
}


# Function to run the container and wait for it to be ready
run_container() {
    print_status "Starting container..."
    CONTAINER_ID=$(docker run --rm -d -p 5432 "$IMAGE_ID")
    print_success "Container started: $CONTAINER_ID"

    print_status "Waiting for database to be ready..."
    if ! docker exec "$CONTAINER_ID" pg_isready -U $USERNAME -d $DATABASE -t "$TIMEOUT" >/dev/null 2>&1; then
        print_error "Database did not become ready within ${TIMEOUT}s"
        exit 1
    fi
    print_success "Database is ready"
}

# Function to execute pg_dump and handle output
execute_pg_dump() {
    if [[ -n "$OUTPUT_FILE" ]]; then
        # Output to file
        print_status "Generating schema dump to $OUTPUT_FILE"
        local output="$OUTPUT_FILE"
    else
        # Output to stdout
        print_status "Generating schema dump to stdout"
        local output="/dev/stdout"
    fi
    local pg_dump_flags="--schema-only \
    --exclude-table=$ALEMBIC_VERSION_TABLE \
    --exclude-table=alembic_version \
    --no-owner \
    -U postgres -d $DATABASE"
    
    # extensions are managed by the init-db script
    # transactional statements are managed by alembic
    # search_path manipulations breaks alembic context
    docker exec "$CONTAINER_ID" \
    bash -c "pg_dump $pg_dump_flags" \
    | grep -vE '(^BEGIN|^COMMIT|EXTENSION|^--\s*$|search_path)' \
    | cat -s >"$output"

    if [[ $? -ne 0 ]]; then
        print_error "Schema dump generation failed"
        exit 1
    elif [[ -s "$OUTPUT_FILE" ]]; then
        local dump_size=$(du -h "$OUTPUT_FILE" | cut -f1)
        print_success "Schema dump generated successfully to $OUTPUT_FILE ($dump_size)"
    else
        print_success "Schema dump generated successfully to stdout"
    fi
}

# Function to cleanup on exit
cleanup() {
    # Stop and remove container if it exists
    if [[ -n "$CONTAINER_ID" ]]; then
        docker stop "${CONTAINER_ID}" >/dev/null 2>&1 || true
        docker rm "${CONTAINER_ID}" >/dev/null 2>&1 || true
    fi
}


# Main execution
main() {
    # Parse command line arguments
    parse_arguments "$@"
    
    # Check output permissions
    check_output_permissions
    
    # Build the Docker image
    build_image
    
    # Run the container and wait for it to be ready
    run_container

    print_status "Starting schema dump generation..."
    
    # Execute pg_dump
    execute_pg_dump

    exit 0
}


# Set trap to cleanup on script exit
trap cleanup EXIT

# Run main function with all arguments
main "$@"
