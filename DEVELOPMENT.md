# Development

The ufw module is using [pdk]. To contribute to this module, please go over the following
checklist and create a pull request after:

* [ ] `pdk test unit` passes.
* [ ] `pdk validate` passes. In case of styling violations,
  `pdk bundle exec rake rubocop:auto_correct` may help.
* [ ] Examples are updated according to the changes.
* [ ] Files are documented using [puppet strings syntax][].
* [ ] [REFERENCE.md][] is updated according to the changes. Command: `pdk bundle exec puppet strings generate --format markdown --out REFERENCE.md`
* [ ] `pre-commit` command shows no failures.

### Pre-commit

This project uses [pre-commit][] to validate commit contents before it's created.
Please follow the corresponding documentation on how to setup and use it.

### Development sandbox

One of the challenging tasks during the development is to create an environment
to quickly test your ideas and thanges. The current section describes an easy way
of running your module in a sandbox.

The manual relies on [pdk][] and [litmus][]. Refer the documentation of corresponding utility for advanced use-cases.

First, provision a container that complies with the [module requirements][]:

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

To apply existing manifest inside of the container ([examples/simplerules.pp][] in this case):

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
[REFERENCE.md]: REFERENCE.md
[puppet strings syntax]: https://puppet.com/docs/puppet/latest/puppet_strings_style.html
[pre-commit]: https://pre-commit.com/
