function build(_, config, parameters, level)
  config.itemName = root.createTreasure(parameters.pool or config.pool, level or 0, math.random(1, 4294967295))[1].name
  return config, {}
end