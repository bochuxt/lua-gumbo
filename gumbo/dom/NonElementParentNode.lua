local assertions = require "gumbo.dom.assertions"
local assertNode = assertions.assertNode
local type = type
local _ENV = nil
local NonElementParentNode = {}

function NonElementParentNode:getElementById(elementId)
    assertNode(self)
    if type(elementId) == "string" then
        for node in self:walk() do
            if node.type == "element" and node.id == elementId then
                return node
            end
        end
    end
end

return NonElementParentNode
