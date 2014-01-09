local Buffer = require "gumbo.util.buffer"
local Indent = require "gumbo.util.indent"

return function(node)
    local buf = Buffer()
    local indent = Indent(2)
    local level = 0
    local function serialize(node)
        if node.type == "element" then
            local i1, i2 = indent[level], indent[level+1]
            if node.tag_namespace ~= "html" then
                buf:appendf('| %s<%s %s>\n', i1, node.tag_namespace, node.tag)
            else
                buf:appendf('| %s<%s>\n', i1, node.tag)
            end
            for name, value, namespace in node:attr_iter_sorted() do
                if namespace then
                    buf:appendf('| %s%s %s="%s"\n', i2, namespace, name, value)
                else
                    buf:appendf('| %s%s="%s"\n', i2, name, value)
                end
            end
            level = level + 1
            for i = 1, #node do
                if node[i].type == "text" and node[i+1]
                   and node[i+1].type == "text"
                then
                    -- Merge adjacent text nodes, as expected by the
                    -- spec and the html5lib tests
                    -- TODO: Why doesn't Gumbo do this during parsing?
                    local text = node[i+1].text
                    node[i+1] = node[i]
                    node[i+1].text = node[i+1].text .. text
                else
                    serialize(node[i])
                end
            end
            level = level - 1
        elseif node.type == "text" or node.type == "whitespace" then
            buf:appendf('| %s"%s"\n', indent[level], node.text)
        elseif node.type == "comment" then
            buf:appendf('| %s<!-- %s -->\n', indent[level], node.text)
        elseif node.type == "document" then
            if node.has_doctype == true then
                local pubid = node.public_identifier
                local sysid = node.system_identifier
                if pubid ~= "" or sysid ~= "" then
                    local fmt = '| <!DOCTYPE %s "%s" "%s">\n'
                    buf:appendf(fmt, node.name, pubid, sysid)
                else
                    buf:appendf("| <!DOCTYPE %s>\n", node.name)
                end
            end
            for i = 1, #node do
                serialize(node[i])
            end
        end
    end
    serialize(node)
    return buf:concat()
end
