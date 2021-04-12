Development hints
=

Development sandbox
===

The easiest option is to use [pdk] and [litmus]. Refer the documentation of those utilities for advanced use-cases.

First, provision a container that complies with the [module requirements]:

```shell
$ pdk bundle exec rake 'litmus:provision[docker, litmusimage/ubuntu:18.04]'
```

Then install the puppet agent to be able to provision the container:

```shell
$ pdk bundle exec rake 'litmus:install_agent'
```

Copy the ufw module to the container. **Do this every time you want to test your changes**:

```shell
$ pdk bundle exec rake 'litmus:install_module'
```

Optionally verify that puppet agent in the container sees our module:

```shell
$ pdk bundle exec bolt command run 'puppet module list' --targets localhost:2222 -i inventory.yaml
```

Connect to the running container (the container id could be found via `docker ps`):

```shell
$ docker exec -it container_id bash
```

Apply the manifest you'd like to test. This should be executed in the container:

```shell
$ /opt/puppetlabs/bin/puppet apply -e 'ufw { "foo": ensure => "present" }' --debug
```

To apply existing manifest inside of the container ([examples/simplerules.pp] in this case):

```shell
docker cp ./examples/simplerules.pp [container_id]:/test.pp && docker exec -it [container_id] /opt/puppetlabs/bin/puppet apply test.pp --debug --verbose
```

To remove the container after you have finished the testing:

```shell
$ pdk bundle exec rake 'litmus:tear_down'
```

[litmus]: https://puppetlabs.github.io/litmus/
[module requirements]: metadata.json
[pdk]: https://puppet.com/try-puppet/puppet-development-kit/
[examples/simplerules.pp]: examples/simplerules.pp
