# openapi-synthesize

This script constructs a complete openapi spec by composing fragments from multiple yaml files found in a wazo python project(for plugin-oriented project structures, usually under 'plugins.*' or 'plugins.http.*' subpackages).

## Install

The script and its dependencies may be installed as a python package.
Since the script needs to import the targeted python project's modules, it is necessary to run the script in an environment where the targeted project and its dependencies are installed(such as a virtual environment created for that project).

```
$ pip install --user . # will install in the user environment
$ # assuming $venvPath points to a virtual env with the targeted project and its dependencies installed therein
$ source $venvPath/bin/activate
$ openapi-synthesize ...
```

## Usage

Generally, the script may be invoked with 3 arguments:
```
openapi-synthesize $subpackage_path $hostname $api_prefix
```
Example:
```
openapi-synthesize wazo_confd.plugins confd /api
```

The last two arguments may be omitted(and will default to what is embedded in the yaml fragments):
```
openapi-synthesize wazo_confd.plugins
```

If an api prefix is specified, the `x-scheme` attribute will be set to `https`, otherwise defaulting to the value embedded in the source yaml(usually http).
