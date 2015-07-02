-- (start) config
local chanceToMutate = 0.1
local chanceToInovate = 0.9

math.randomseed( os.time() )

function shouldMutate()
  return math.random(0,1) < chanceToMutate
end

function shouldInovate()
  return math.random(0,1) < chanceToInovate
end
-- (end) config

-- (start) utils
function compareFitness(a,b)
  return a.fitness > b.fitness
end

function biasedRandom(population)
  local biasedPopulation = {}
  local k = 1
  for i=1,#population do
    local qtt = math.ceil(population[i].chanceToBreed*100) + 1
    for j=1,qtt do
      biasedPopulation[k] = i
      k = k + 1
    end
  end

  return biasedPopulation[math.random(1,#biasedPopulation)]
end
-- (end) utils

-- (start) people
function newSpecimen()
  local specimen = {}
  specimen.fitness = 1
  specimen.chanceToBreed = 0
  specimen.generation = 0
  specimen.genomes = {}

  return specimen;
end

function emptyPopulation(size)
  local population = {}
  for i=1,size do
    population[i] = newSpecimen()
  end

  return population
end

function orderPopulation(population)
  table.sort(population, compareFitness)
end

function orderPopulationByChanceToBreed(population)
  table.sort(population, compareFitness)
end

function renewPopulation(population, generation)
  orderPopulation(population)

  local totalFitness = 0
  for i=1,#population do
    totalFitness = totalFitness + population[i].fitness
  end

  for i=1,#population do
    if (totalFitness <= 0) then
      population[i].chanceToBreed = 0
    else
      population[i].chanceToBreed = population[i].fitness / totalFitness
    end
  end

  local idxMale = biasedRandom(population)
  local idxFemale = biasedRandom(population)

  local male = population[idxMale]
  local female = population[idxFemale]

  local children = breedChildren(male, female, generation)

  population[#population-1] = children["first"]
  population[#population] = children["second"]

  orderPopulation(population)
end
-- (end) people

-- (start) reproductionCenter
function breedChildren(male, female, generation)
	local firstChild = newSpecimen()
  local secondChild = newSpecimen()
  local randomDivisor = 0

  firstChild.generation = generation
  secondChild.generation = generation

  local maxSize = math.min(#male.genomes, #female.genomes)

  if (maxSize > 0) then
     randomDivisor = math.random(1,maxSize)
  end

  for i=1,randomDivisor do
    firstChild.genomes[i] = male.genomes[i]
    secondChild.genomes[i] = female.genomes[i]
  end

  for i=randomDivisor+1,#female.genomes do
    firstChild.genomes[i] = female.genomes[i]
  end

  for i=randomDivisor+1,#male.genomes do
    secondChild.genomes[i] = male.genomes[i]
  end

	mutate(firstChild)
  mutate(secondChild)

	return {["first"]=firstChild, ["second"]=secondChild}
end

function mutate(child)
  if (shouldInovate) then
    child.genomes[#child.genomes+1] = "a"
  end
end
-- (end) reproductionCenter

-- (start) fitness
function calculateFitness(specimen)
  if specimen.genomes == nil then
    return 0
  end

  specimen.fitness = #specimen.genomes + 1
end
-- (end) fitness

-- (start) Run loop
local population = emptyPopulation(10)

for k=1,10 do
  print("Generation: " .. k)

  for i=1,#population do
    calculateFitness(population[i])
  end

  orderPopulation(population)
  for i=1,#population do
    print(population[i].fitness)
  end

  renewPopulation(population, k)
end
-- (end) Run loop
