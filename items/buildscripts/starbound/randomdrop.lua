function build(_, config, parameters, level)
  config.itemName = root.createTreasure(parameters.pool or config.pool or config.itemName, level or 0)[1].name
  return config, {}
end