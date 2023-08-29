require "/scripts/versioningutils.lua"

function build(directory, config, parameters)
  config.directives = parameters.directives or config.directives or ""
  if config.directives then
    replacePatternInData(config, nil, "<directives>", config.directives)
  end
  return config, parameters
end