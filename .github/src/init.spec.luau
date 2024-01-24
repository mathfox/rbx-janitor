return function()
    local Janitor = require(script.Parent)

    describe("is", function()
        it("should return true if the passed value is a Janitor", function()
            expect(Janitor.is(Janitor.new())).to.equal(true)
        end)

        it(
            "should return false iff the passed value is anything else",
            function()
                expect(Janitor.is({})).to.equal(false)
                expect(Janitor.is("Janitor")).to.equal(false)
            end
        )
    end)

    describe("new", function()
        it("should create a new Janitor", function()
            expect(Janitor.new()).to.be.ok()
        end)
    end)

    local function noop() end

    describe("addFunction", function()
        it("should add things", function()
            local janitor = Janitor.new()

            expect(function()
                janitor:addFunction(noop)
            end).never.to.throw()
        end)

        it("should add things with the given key", function()
            local janitor = Janitor.new()

            expect(function()
                janitor:addFunction(noop, "key")
            end).never.to.throw()
        end)

        it("should overwrite keys", function()
            local janitor = Janitor.new()

            local wasRemoved = false

            janitor:addFunction(function()
                wasRemoved = true
            end, "key")

            janitor:addFunction(noop, "key")

            expect(wasRemoved).to.equal(true)
        end)

        it("should clean up everything correctly", function()
            local NewJanitor = Janitor.new()
            local cleanedUpTimes = 0
            local totalIterations = 5000

            for key = 1, totalIterations do
                NewJanitor:addFunction(function()
                    cleanedUpTimes += 1
                end, key)
            end

            for key = totalIterations, 1, -1 do
                NewJanitor:clean(key)
            end

            expect(cleanedUpTimes).to.equal(totalIterations)
        end)
    end)

    describe("remove", function()
        it("should remove the clean handler without invoking it", function()
            local janitor = Janitor.new()
            local wasRemoved = false

            janitor:addFunction(function()
                wasRemoved = true
            end, "key")

            janitor:remove("key")

            expect(wasRemoved).to.equal(false)
        end)
    end)

    describe("clean", function()
        it("should invoke a clean handler", function()
            local janitor = Janitor.new()
            local wasRemoved = false

            janitor:addFunction(function()
                wasRemoved = true
            end, "key")

            janitor:clean("key")

            expect(wasRemoved).to.equal(true)
        end)
    end)

    describe("cleanup", function()
        it("should cleanup everything", function()
            local janitor = Janitor.new()
            local TotalRemoved = 0
            local FunctionsToAdd = 500

            for _ = 1, FunctionsToAdd do
                janitor:addFunction(function()
                    TotalRemoved += 1
                end)
            end

            janitor:cleanup()
            expect(TotalRemoved).to.equal(FunctionsToAdd)

            for _ = 1, FunctionsToAdd do
                janitor:addFunction(function()
                    TotalRemoved += 1
                end)
            end

            janitor:cleanup()
            expect(TotalRemoved).to.equal(FunctionsToAdd * 2)
        end)
    end)

    describe("destroy", function()
        it("should cleanup everything", function()
            local janitor = Janitor.new()
            local TotalRemoved = 0
            local FunctionsToAdd = 500

            for _ = 1, FunctionsToAdd do
                janitor:addFunction(function()
                    TotalRemoved += 1
                end)
            end

            janitor:destroy()

            expect(TotalRemoved).to.equal(FunctionsToAdd)
        end)

        it("should not allow methods usage after being destroyed", function()
            local janitor = Janitor.new()

            janitor:destroy()

            expect(function()
                janitor:addFunction(noop)
            end).to.throw()
        end)
    end)
end
