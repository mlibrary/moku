# Fauxpaas Design

This page contains a general overview of how the software is designed.  It
is not a guide for how to use it--that comes later.

To begin, this project is implemented as a command-line utility. Many commands
modify or query the program's state. It has no notion of sessions.


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
faux
 |- permissions.yml             global whitelist
 |- instances
 |  |- myapp                    app dir
 |  |  |- permissions.yml       app whitelist
 |  |  |- prod                  stage dir
 |  |  |  |- permissions.yml    stage whitelist
 |  |  |  |- instance.yml
 |  |  |  |- releases.yml       release history
 |  |  |- test                  we call myapp-test a "named instance"
 |  |- yourapp
 |- deploy (git)                branch-per-instance
 |  |- deploy.yml               deploy config
 |- infrastructure (git)        branch-per-instance
 |  |- infrastructure.yml       infrastructure config
faux-app                        this code
```

## Authorization and Authentication

This project assumes that an underprivileged user ("the user") elevated its privileges to become
a privileged, non-root user. This latter user is the application user, and all commands are run
with its identity. The software must be able to access the real user's username.

From there, the CLI verifies that the user is allowed to run the given command on the given
target. It does so by instantiating the ApplicationPolicy with the user object and the target
object, and asking the policy if the command is allowed.

The ApplicationPolicy itself will look in the following locations for files named `permissions.yml`.
The order does not matter.

* The folder of the named instance
* The folder of the app to which the named instance belongs
* The top-level folder

We understand the following permissions:

| Permission | Description |
| --- | --- |
| view | View the configuration of the current and past deployments. |
| log | View the instance's application and system logs. |
| deploy | Deploy and rollback the application. Implies view. |
| all | Implies all other permissions. |

The ApplicationPolicy, and thus the authorization mechanism, is not accessed beyond this
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
1. Run before_build hooks
1. Build the application
1. Run after_build hooks
1. Set this release as the current release
1. Log the successful deployment
1. Run after_release hooks

Should any step fail, the process ends and the subsequent steps are skipped.

_Note: Failed deployments still consume one of the cache slots._


## History

We keep a log of every successful deployment.

> TIMESTAMP: USER deployed SRC CONFIG INFRA with DEPLOY

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

## Developer Config Repo Structure

```
/
 |- after_build.yml             contains after_build commands
 |- after_release.yml           contains after_release commands
 |- yourdir
 |  |- yourfile.cfg             will be installed to yourdir/yourfile.cfg
 |- yourotherfile.txt           will be installed to /yourotherfile.txt
```

The files `after_build.yml` and `after_release.yml` are not installed with the application.

# Examples

The included examples can be used for end-to-end testing:

* test-norails
* test -rails

