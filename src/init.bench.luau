local Janitor = require(script.Parent)
local new = Janitor.Janitor.new
local is = Janitor.is
local clock = os.clock
local huge = math.huge
local fmt = string.format

local FLOAT_PRECISION = 3

type BenchmarkUnit = "ms" | "μs" | "ns"

local UNIT_MAP: { [BenchmarkUnit]: number } = {
    ["ms"] = 1_000,
    ["μs"] = 1_000_000,
    ["ns"] = 1_000_000_000,
}

type BenchmarkOptions = {
    unit: BenchmarkUnit?,
    decimalPrecision: number?,
}

type BenchmarkFn = (iteration: number) -> ()

local function benchmark(
    name: string,
    iterations: number,
    fn: BenchmarkFn,
    options: BenchmarkOptions?
)
    local unit = "ms"

    if options and options.unit then
        unit = options.unit
    end

    local unitMultiplier = UNIT_MAP[unit]

    local elapsed = 0
    local min = huge
    local max = -huge

    for iterationIndex = 1, iterations do
        local now = clock()
        fn(iterationIndex)

        local passed = clock() - now
        elapsed += passed

        if passed < min then
            min = passed
        end

        if passed > max then
            max = passed
        end
    end

    local avg = elapsed / iterations

    local precision = options and options.decimalPrecision or FLOAT_PRECISION
    local precisionStr = `%.{precision}f`
    local rawFmtStr =
        `\n\tBenchmark results for "{name}" are:\n\t- {iterations} function calls.\n\t- {precisionStr} {unit} avg.\n\t- {precisionStr} {unit} min.\n\t- {precisionStr} {unit} max.\n`

    print(
        fmt(
            rawFmtStr,
            avg * unitMultiplier,
            min * unitMultiplier,
            max * unitMultiplier
        )
    )
end

local exports = {}

local function benchNew()
    local newIterations = 10_000_000

    benchmark("Janitor.new", newIterations, function()
        local _janitor = new()
    end)
end
exports.benchNew = benchNew

local function benchIs()
    local isIterations = 10_000_000
    local options: BenchmarkOptions = {
        unit = "μs",
        decimalPrecision = 6,
    }

    do
        local janitor = new()

        benchmark("Janitor.is with Janitor provided", isIterations, function()
            local _isJanitor = is(janitor)
        end, options)
    end

    do
        local nonJanitor = {}

        benchmark(
            "Janitor.is with non-Janitor value provided",
            isIterations,
            function()
                local _isJanitor = is(nonJanitor)
            end,
            options
        )
    end
end
exports.benchIs = benchIs

local function benchAdd()
    local addIterations = 10_000_000
    local janitor = new()

    local instance = {
        destroy = function() end,
    }

    benchmark("Janitor:add", addIterations, function()
        janitor:add(instance, "destroy")
    end)

    benchmark(
        "Janitor:add with key provided",
        addIterations,
        function(iteration)
            janitor:add(instance, "destroy", iteration)
        end
    )
end
exports.benchAdd = benchAdd

local function benchAddFn()
    local addFnIterations = 10_000_000
    local janitor = new()

    local function cleanup() end

    benchmark("Janitor:addFn", addFnIterations, function()
        janitor:addFn(cleanup)
    end)

    benchmark(
        "Janitor:addFn with key provided",
        addFnIterations,
        function(iteration)
            janitor:addFn(cleanup, iteration)
        end
    )
end
exports.benchAddFn = benchAddFn

function exports.benchAll()
    benchNew()
    benchIs()
    benchAdd()
    benchAddFn()
    -- benchmark("Janitor:add", 1_000_000, function() end)

    -- benchmark("Janitor:add", 1_000_000, function() end)

    -- benchmark("Janitor:add", 1_000_000, function() end)
end

table.freeze(exports)

return exports
