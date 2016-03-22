# create heroku apps for Kapost ecosystem
#
class Heroku::Command::Cabbage < Heroku::Command::Base
  KAPOST_ENVS = [
    { name: 'staging',  pipeline_stage: 'development' },
    { name: 'staging2', pipeline_stage: 'development' },
    { name: 'staging3', pipeline_stage: 'development' },
    { name: 'demo',     pipeline_stage: 'staging' },
    { name: 'prod',     pipeline_stage: 'production' }
  ].freeze

  DEPLOY_EMAIL_RECIPIENTS = 'pe@kapost.com deploynotifications@kapost.com'

  # cabbage:provision APP_NAME
  #
  # Provisions a new app for all Kapost deploy environments
  #
  # -s, --slack TOKEN # The slack channel token for deployhook config
  #
  def provision
    base_name = args.shift

    unless base_name
      error('Do you need help finding a cabbage name? Here are some suggestions: https://en.wikipedia.org/wiki/Cruciferous_vegetables#List_of_cruciferous_vegetables')
    end

    validate_arguments!

    slack_token = options[:slack]

    message = []
    message << 'This action will:'
    message << ''
    message << '1. Install heroku-pipelines addon'
    message << "2. Create the Heroku apps #{app_names_to_create(base_name)}"
    message << "3. Add email deploy hook for #{DEPLOY_EMAIL_RECIPIENTS}"
    message << "4. Add deploy hook to Slack webhook #{slack_webhook_url(slack_token)}" if slack_token
    message << ''
    message << 'Are you sure you want to continue? (y/n)'
    return unless confirm(message.join("\n"))

    install_pipelines

    KAPOST_ENVS.each.with_index do |env, index|
      heroku_name = "#{base_name}-#{env[:name]}c"

      create_heroku_app(heroku_name, slack_token)
      add_app_to_pipeline(app_name, heroku_name, env[:pipeline_stage], index == 0)
    end
  end

  private

  def app_names_to_create(app_name)
    KAPOST_ENVS.map { |env| "#{app_name}-#{env[:name]}c" }.join(' ')
  end

  def install_pipelines
    system('heroku plugins:install heroku-pipelines')
  end

  def add_app_to_pipeline(pipeline_name, heroku_app, stage, is_first_run)
    if is_first_run
      system("heroku pipelines:create #{pipeline_name} -a #{heroku_app} --stage #{stage}")
    else
      system("heroku pipelines:add #{pipeline_name} -a #{heroku_app} --stage #{stage}")
    end
  end

  def create_heroku_hooks(heroku_name, heroku_slack_token)
    system("heroku addons:create deployhooks:email --app #{heroku_name} --recipient=\"#{DEPLOY_EMAIL_RECIPIENTS}\" --subject=\"Deployed $1 to $i\" --body=\"{{git_log}}\"")

    if heroku_slack_token
      system("heroku addons:create deployhooks:http --app #{heroku_name} --url=#{slack_webhook_url(heroku_slack_token)}")
    end
  end

  def slack_webhook_url(token)
    "https://kapost.slack.com/services/hooks/heroku?token=#{token}"
  end

  def create_heroku_app(heroku_name, heroku_slack_token)
    system("heroku apps:create #{heroku_name} -o kapost")
    create_heroku_hooks(heroku_name, heroku_slack_token)
  end
end
