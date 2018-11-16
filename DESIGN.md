# Moku Design

This page contains a general overview of how the software is designed.  It
is not a guide for how to use it--that comes later.

To begin, this project is implemented as a command-line utility. Many commands
modify or query the program's state. It has no notion of sessions.

## Getting Up and Running

This project currently requires ruby 2.4.x, and doesn't quite support ruby 2.5.x. Ruby
must be installed with rbenv, and the environment RBENV\_ROOT needs to point to your
installation. Your rbenv install should handle that automatically. If you have
rbenv-aliases installed, the project will pin to 2.4. Otherwise, ensure that the shell and
subshells will run in 2.4.x.

When you create a PR, code climate will yell at you. Rubocop is built into the repo, and can be
run with `bundle exec rubocop`. Try `--help`

### Unit Tests

`git clone, bundle install, bundle exec rspec`

The unit tests should pass out of the box.

### Integration Tests

The integration tests currently require that you can ssh to localhost without a password
via ssh keypair. The ssh key should be stored in $HOME/.ssh/id\_rsa-moku. Simply symlinking
any sshkey you've already set up should accomplish this.

99% of the test run time is the integration tests, which are tagged as "integration".
You can skip them by using rspec's tag feature, e.g. `--tag ~integration` will skip them,
and just drop the tilde to only run the integration specs.

Finally, the integration specs don't provide a lot of information when they fail by default.
Set the environment variable `DEBUG` to `true` to see verbose output.

### Additional Steps on Mac

You need SSHD running, and you also need a symlink to rbenv.

    $ sudo systemsetup -setremotelogin on
    $ mkdir ~/.rbenv/bin
    $ ln -s /usr/local/bin/rbenv ~/.rbenv/bin/rbenv

## Named Instance

The application primarily interacts with what we are calling "named instances". A named instance
is a specific application + environment name to be deployed. Most applications will have multiple
named instances, e.g. myapp-production and myapp-testing. It is generally assumed that the source
code for all of an app's named instances is the same (albeit possibly at different versions), while
their configuration differs.

Internally, they are represented by objects of the Instance class in code, and as a folder on disk
otherwise. We often shorten this name to simply "instance".

## Parts

### Source Code

The code being deployed. This is supplied from an external git repository. The location
is set in the deployment configuration. This is accessed via an ssh key that has been
granted access to the repository; for most repos, this will be an organization-wide key.

### Developer Configuration

Configuration set by developers; includes everything that is not infrastructure configuration.
This is supplied from an external git repository that is shared by all instances; a given
instance's dev config is on a shared branch. Developers manage their own access, while the
application has read-only access to all branches.  The branch matches the instance's name.

### Infrastructure Configuration

Configuration set by infrastructure administrators, such as application user IDs, database
connection strings, and connection information for other managed services. This is kept
separate from other configuration so that it can change independently.

Because it is useful to know if infrastructure changed, at least a log of when changes
occurred will be available to developers.

Infrastructure configuration will be available in the file `infrastructure.yml` in the
base directory of your deployed application. We'll need to define the format used to
represent various services in some place public, such as confluence.

### Deployment Configuration

A configuration file that drives the deployment machinery. It includes config that is tied
to the infrastructure that is needed at deploy-time instead of runtime, e.g. the servers
where the instance will be deployed.


## Folder Structure

```
moku
 |- permissions.yml             global whitelist
 |- data
 |  |- instances
 |  |  |- myapp-prod            app dir
 |  |  |  |- permissions.yml    stage whitelist
 |  |  |  |- instance.yml
 |  |  |  |- hosts.rb           file describing hosts
 |  |  |- myapp-test
 |  |  |- yourapp-prod
 |  |- stages
 |  |  |- myapp-prod.rb
 |  |  |- myapp-test.rb
 |- releases
 |  |- myapp-prod.yml           release history
 |- deploy (git)                branch-per-instance
 |  |- deploy.yml               deploy config
 |- infrastructure (git)        branch-per-instance
 |  |- infrastructure.yml       infrastructure config
lib                             this code
```

## Authorization and Authentication

This project assumes that an underprivileged user ("the user") elevated its privileges to become
a privileged, non-root user. This latter user is the application user, and all commands are run
with its identity. The software must be able to access the real user's username.

Moku does not provide any authentication method.

The identity use is expected to be specified on the command line.
From there, the CLI verifies that the user is allowed to run the given command on the given
target. It does so by instantiating a Policy from the user object, which can then be interrogated
for permisions. This mechanism is not especially advanced; therefore, should the authorization
scope of Moku increase significantly, more robust mechanisms should be used.

The Policy itself will look in the following locations for files named `permissions.yml`.
The order does not matter.

* The folder of the named instance
* ~~The folder of the app to which the named instance belongs~~
* The top-level folder

We understand the following permissions:

| Role | Description |
| --- | --- |
| read | Read the configuration of the current and past deployments, and view logs. |
| restart | Restart the application. |
| edit | Edit the instance's configuration. Implies read. |
| deploy | Deploy and rollback the application. Implies restart, read. |
| admin | Implies all other permissions. |

The Policy, and thus the authorization mechanism, is not accessed beyond this
point.


## Releases

The result of a successful deploy operation is the creation of a new *release*. Strictly speaking,
a release is defined by the following information:

* the user that deployed it
* when it was deployed
* Repo+SHA of the source code
* Repo+SHA of the developer configuration
* SHA of the infrastructure configuration
* SHA of the deployment machinery

### Cached Releases

The most recent few releases are kept on the servers to which they were deployed. The active release
is set by a symlink. This allows for rapid rollback.


## Deployment aka Creating a Release

The process is as follows:

1. Create a new, empty cache
1. Copy the source code
1. Copy the developer configuration
1. Copy the infrastructure configuration
1. Run before\_build hooks
1. Build the application
1. Run after\_build hooks
1. Set this release as the current release
1. Log the successful deployment
1. Run after\_release hooks

Should any step fail, the process ends and the subsequent steps are skipped.

_Note: Failed deployments still consume one of the cache slots._


## History

We keep a log of every successful deployment.

* TIMESTAMP: When deployment process completed
* USER: The user who initiated it
* SRC: commit identifier (SHA) of the source code deployed
* CONFIG: commit identifier (SHA) (from an external repo) of the developer
  configuration used for the deployment
* INFRA: commit identifier (SHA) of the infrastructure configuration used
* DEPLOY: commit identifier (SHA) (from an external repo) of the deployment
  configuration - this will be generated by predeployment - essentially this
  identifies the set of machines deployed to - i.e. the 'stage' as capistrano
  calls it


## Example Deploy Config (deploy.yml)

```
deploy_dir: "/hydra/dromedary-production"
env:
  rack_env: production
  some_var: some_val
systemd_services:
  - dromedary-production.target
sites:
  macc:
    - macc1
    - hostname: macc2
  hatcher:
    - hostname: hatcher1
    - hostname: hatcher2
    - hostname: hatcher3
```

## Developer Config Repo Structure

```
/
 |- finish_build.yml             contains finish_build commands
 |- after_release.yml           contains after_release commands
 |- yourdir
 |  |- yourfile.cfg             will be installed to yourdir/yourfile.cfg
 |- yourotherfile.txt           will be installed to /yourotherfile.txt
```

The structure of `finish_build.yml` and `after_release.yml` is as follows:

```yaml
---
- cmd: FOO=bar somebin.sh -f --target=sandwich # The full command to run
- cmd: bundle exec rake some_other_command
```

# Examples

The included examples can be used for end-to-end testing:

* test-norails
* test-rails

