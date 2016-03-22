# heroku-cabbage

Provision Kapost organization applications for every deployment environment with one command,
complete with pipeline stages, email deployment hook, and optional http deployment hook.

---

### Installation

`heroku plugins:install https://github.com/kapost/heroku-cabbage.git`

### Example Usage

`heroku cabbage:provision myapp --hook https://hooks.slack.com/blah/token`
