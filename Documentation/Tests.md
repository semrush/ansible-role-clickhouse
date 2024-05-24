## Running Molecule tests locally

### Prerequisites

- Docker
- *Python 3.11*

### Create & activate Python virtual environment by running following commands

```sh
python3 -m venv ./venv
source ./venv/bin/activate
pip install -r requirements-test.txt
```

### Bind Molecule to your Docker daemon socket by running e.g _(optional)_

```sh
export DOCKER_HOST=unix:///var/run/docker.sock
```

### Now you should be able to run Molecule [commands](https://ansible.readthedocs.io/projects/molecule/usage/#valid-actions)

```sh
# Prepare test instance
molecule create

# Run default scenario (apply role) on test instance
molecule converge

# Run verifications on applied role
molecule verify

# Stop & remove test instance
molecule destroy

# Run full test cycle for specified host & clickhouse versions
DISTRO_NAME=debian DISTRO_VER=12 CLICKHOUSE_VER=23.10.6.60 molecule test

# Use ANSIBLE_VERBOSITY to increase ansible output verbosity
ANSIBLE_VERBOSITY=3 molecule test
```
