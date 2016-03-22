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

  DEPLOY_EMAIL_RECIPIENTS = 'pe@kapost.com deploynotifications@kapost.com'.freeze

  # cabbage:provision APP_NAME
  #
  # Provisions a new app for all Kapost deploy environments
  #
  # --hook URL # optional deploy hook URL
  #
  def provision
    base_name = args.shift

    unless base_name
      error('Do you need help finding a cabbage name? https://en.wikipedia.org/wiki/Cruciferous_vegetables#List_of_cruciferous_vegetables')
    end

    http_hook = options[:hook]

    message = []
    n = 0
    message << 'This action will:'
    message << ''
    message << "#{n += 1}. Install heroku-pipelines addon" unless pipelines_installed?
    message << "#{n += 1}. Create the Heroku apps #{app_names_to_create(base_name)} in pipeline #{base_name}"
    message << "#{n += 1}. Add email deploy hook for #{DEPLOY_EMAIL_RECIPIENTS}"
    message << "#{n += 1}. Add http deploy hook #{http_hook}" if http_hook
    message << ''
    message << 'Are you sure you want to continue? (y/n)'
    return unless confirm(message.join("\n"))

    install_pipelines

    KAPOST_ENVS.each.with_index do |env, index|
      heroku_name = "#{base_name}-#{env[:name]}c"

      create_heroku_app(heroku_name, http_hook)
      add_app_to_pipeline(base_name, heroku_name, env[:pipeline_stage], index == 0)
    end
  end

  private

  def app_names_to_create(app_name)
    KAPOST_ENVS.map { |env| "#{app_name}-#{env[:name]}c" }.join(' ')
  end

  def pipelines_installed?
    `heroku plugins` =~ /^heroku-pipelines@/
  end

  def install_pipelines
    shell('heroku plugins:install heroku-pipelines') unless pipelines_installed?
  end

  def add_app_to_pipeline(pipeline_name, heroku_app, stage, is_first_run)
    add_or_create = is_first_run ? 'create' : 'add'
    shell("heroku pipelines:#{add_or_create} #{pipeline_name} -a #{heroku_app} --stage #{stage}")
  end

  def create_heroku_hooks(heroku_name, http_hook)
    shell("heroku addons:create deployhooks:email --app #{heroku_name} --recipient=\"#{DEPLOY_EMAIL_RECIPIENTS}\" --subject=\"Deployed $1 to $i\" --body=\"{{git_log}}\"")
    shell("heroku addons:create deployhooks:http --app #{heroku_name} --url=#{http_hook}") if http_hook
  end

  def create_heroku_app(heroku_name, http_hook)
    shell("heroku apps:create #{heroku_name} -o kapost")
    create_heroku_hooks(heroku_name, http_hook)
  end

  def shell(command)
    unless system(command)
      error("The last command failed with error status #{$?}")
    end
  end
end
