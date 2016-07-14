# heroku-cabbage

Provision Kapost organization applications for every deployment environment with one command,
complete with pipeline stages, email deployment hook, and optional http deployment hook.

---

## Installation

`heroku plugins:install https://github.com/kapost/heroku-cabbage.git`

## Example Usage

`heroku cabbage:provision myapp --hook https://hooks.slack.com/blah/token`

### Ignore Errors

To continue provisioning when one command fails, use `--continue_on_error`.
This is useful when provisioning staging apps but pilyr and production have
already been set up.
