module SmartMeta
  def smart_meta_for(kind)
    key = [params[:controller], params[:action], kind].compact.join('.')
    if (title_template = translation_for(key))
      needed_args = title_template.scan(/\{\{(.*?)\}\}/).flatten
      args = needed_args.inject({}) do |hash, arg|
        hash[arg.to_sym] = value_from_arg(arg)
        hash
      end
      I18n.t(key, args)
    end
  end

  def smart_description
    smart_meta_for(:description)
  end

  def smart_keywords
    smart_meta_for(:keywords)
  end

  def smart_title
    smart_meta_for(:title)
  end

  private

  def translation_for(key)
    key.present? && I18n.backend.send(:lookup, I18n.locale || I18n.default_locale, key)
  end

  def value_from_arg(arg)
    parts = arg.split('.')
    # see if we're dealing with an instance variable
    if parts[0].starts_with?('@')
      ret = instance_variable_get(parts.shift)
    else
      ret = send(parts.shift)
    end

    # send the rest of our messages
    parts.each do |part|
      ret = ret.send(part)
    end
    ret
  end
end
