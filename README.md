# heroku-cabbage

Provision Kapost organization applications for every deployment environment with one command,
complete with pipeline stages, email deployment hook, and optional http deployment hook.

---

## "New" Heroku Toolbelt

### Installation

```bash
$ git clone git@github.com:kapost/heroku-cabbage.git
```

### Example Usage

```bash
$ cd heroku-cabbage
$ bin/cabbage-provision myapp --hook https://hooks.slack.com/blah/token
```

## "Old" Heroku Toolbelt

### Installation

```bash
$ heroku plugins:install https://github.com/kapost/heroku-cabbage.git
```

### Example Usage

```bash
$ heroku cabbage:provision myapp --hook https://hooks.slack.com/blah/token
```

## Ignore Errors

To continue provisioning when one command fails, use `--continue-on-error`.
This is useful when provisioning staging apps but pilyr and production have
already been set up.
