#!/usr/bin/env lua

local xml2lua = require "xml2lua"
local xml_handler = require "xmlhandler.tree"

local parallel_degree_kilometers = {
    [0] = 111,
    [1] = 111,
    [2] = 111,
    [3] = 111,
    [4] = 111,
    [5] = 110,
    [6] = 110,
    [7] = 110,
    [8] = 110,
    [9] = 109,
    [10] = 109,
    [11] = 109,
    [12] = 108,
    [13] = 108,
    [14] = 108,
    [15] = 107,
    [16] = 107,
    [17] = 106,
    [18] = 105,
    [19] = 105,
    [20] = 104,
    [21] = 103,
    [22] = 103,
    [23] = 102,
    [24] = 101,
    [25] = 100,
    [26] = 100,
    [27] = 99,
    [28] = 98,
    [29] = 97,
    [30] = 96,
    [31] = 95,
    [32] = 94,
    [33] = 93,
    [34] = 92,
    [35] = 91,
    [36] = 90,
    [37] = 89,
    [38] = 87,
    [39] = 86,
    [40] = 85,
    [41] = 84,
    [42] = 82,
    [43] = 81,
    [44] = 80,
    [45] = 78,
    [46] = 77,
    [47] = 76,
    [48] = 74,
    [49] = 73,
    [50] = 71,
    [51] = 70,
    [52] = 68,
    [53] = 67,
    [54] = 65,
    [55] = 63,
    [56] = 62,
    [57] = 60,
    [58] = 59,
    [59] = 57,
    [60] = 55,
    [61] = 54,
    [62] = 52,
    [63] = 50,
    [64] = 48,
    [65] = 47,
    [66] = 45,
    [67] = 43,
    [68] = 41,
    [69] = 40,
    [70] = 38,
    [71] = 36,
    [72] = 34,
    [73] = 32,
    [74] = 30,
    [75] = 28,
    [76] = 27,
    [77] = 25,
    [78] = 23,
    [79] = 21,
    [80] = 19,
    [81] = 17,
    [82] = 15,
    [83] = 13,
    [84] = 11,
    [85] = 9,
    [86] = 7,
    [87] = 5,
    [88] = 3,
    [89] = 1,
    [90] = 0,
}

local meridian_degree_kilometers = 111
local quadkm_side = 50

local function sign(val)
    if val > 0 then
        return 1
    end
    if val < 0 then
        return -1
    end

    return 0;
end

local function geocoord_to_quadkm(lon, lat)
    local result = {
        lon = lon,
        lat = lat,
    }
    local parallel_len = parallel_degree_kilometers(math.floor(lat) * sign(lat))

    _, result.col = math.round(math.modf(lon) * parallel_len)
    _, result.row = math.round(math.modf(lat) * meridian_degree_kilometers)
end

local function geocoord_to_chunk(lon, lat)
    local result = {
        lon = lon,
        lat = lat,
    }
    local parallel_len = parallel_degree_kilometers(math.floor(lat) * sign(lat))

    _, result.col = math.round(math.modf(lon) * parallel_len)
    _, result.row = math.round(math.modf(lat) * meridian_degree_kilometers)
    _, result.ccl = math.round(math.modf(lon) * parallel_len / quadkm_side)
    _, result.crw = math.round(math.modf(lat) * meridian_degree_kilometers / quadkm_side)
end

local filename = arg[1]

if not filename then
    print("Usage:\n./parse_geo.lua <filename>")
    return 1
end

local in_file = io.open(filename, "rb")
if not in_file then
    print("Unable to open input file")
    return 1
end

local in_content = in_file:read("*all")
in_file:close()

local parser = xml2lua.parser(xml_handler)
parser:parse(in_content)

local features = {
    "aeroway",
    "amenity",
    "amenity_1",
    "barrier",
    "building",
    "club",
    "craft",
    "ford",
    "golf",
    "healthcare",
    "highway",
    "historic",
    "landuse",
    "leisure",
    "man_made",
    "natural",
    "office",
    "place",
    "power",
    "railway",
    "route",
    "shop",
    "telecom",
    "tourism",
    "waterway",
}

local function req_features(features)
   local result = {}

    for _, v in ipairs(features) do
        result[v] = require("parse_geo.defs.features." .. v)
    end

    return result
end

local defs = {
    properties = require "parse_geo.defs.properties",
    features = req_features(features),
    ignored_tags = require "parse_geo.defs.ignored_tags",
    swap_tags = require "parse_geo.defs.swap_tags",
}

local function features_empty_tables(features)
   local tables = {}

    for _, v in ipairs(features) do
        tables[v] = {}
    end

    return tables
end

local processed = {
    nodes = {},
    ways = {},
    relations = {},
    feature_types = features_empty_tables(features),
    unknown_features = features_empty_tables(features),
    unknown_elements = {},
    unknown_tags = {},
}

local function extract_prefix_as_property(element_data, tag, prefix)
    if string.find(tag._attr.k, prefix .. ":") then
        tag._attr.k = string.sub(tag._attr.k, string.len(prefix) + 2, -1)
        element_data[prefix] = yes
    end
end

local function extract_features_from_tag(element_data, tag, defs, features)
    local feature_found = false

    for _, feature in ipairs(features) do
        if tag._attr.k == feature then
            feature_found = true

            if defs.features[feature].ignored[tag._attr.v] then
                goto continue
            end

            local swap = defs.features[feature].swaps_to_properties[tag._attr.v]
            if swap then
                element_data[swap[1]] = swap[2]
                goto continue
            end

            element_data[feature] = defs.features[feature].swaps[tag._attr.v]
                and defs.features[feature].swaps[tag._attr.v]
                or tag._attr.v
        end
        ::continue::
    end

    return feature_found
end

local function extract_element_data_from_tag(element_data, tag, processed, defs, features)
    if string.find(tag._attr.k, "demolished:") then
        return
    end

    extract_prefix_as_property(element_data, tag, "abandoned")
    extract_prefix_as_property(element_data, tag, "disused")

    if defs.swap_tags[tag._attr.k] then
        tag._attr.k = defs.swap_tags[tag._attr.k]
    end

    if defs.ignored_tags[tag._attr.k]
     or extract_features_from_tag(element_data, tag, defs, features) then
        return
    end

    if defs.properties[tag._attr.k] then
        element_data[tag._attr.k] = tag._attr.v

        return
    end

    processed.unknown_tags[tag._attr.k] = true
end

local function extract_childs_from_way(way_data, way, processed)
    way_data.childs = {}

    for _, nd in ipairs(way.nd) do
        table.insert(way_data.childs, nd._attr.ref)
    end

    processed.ways[way_data.id] = way_data
end

local function extract_childs_from_relation(relation_data, relation, processed)
    relation_data.childs = {}

    for _, member in ipairs(relation.member) do
        table.insert(relation_data.childs, member._attr.ref)
    end

    processed.relations[relation_data.id] = relation_data
end

local function process_element_features(element_data, processed, defs, features)
    for _, feature in ipairs(features) do
        if element_data[feature] then
            if not defs.features[feature].properties[element_data[feature]] then
                processed.unknown_features[feature][element_data[feature]] = true
            end
            processed.feature_types[feature][element_data[feature]] = processed.feature_types[feature][element_data[feature]]
                and processed.feature_types[feature][element_data[feature]] + 1
                or 1
        end
        ::continue::
    end
end

local function element_has_features(element_data, features)
    for _, feature in ipairs(features) do
        if element_data[feature] then
            return true
        end
    end

    return false
end

local function process_elements(elements, processed, defs, features, type)
    for _, element in ipairs(elements) do
        local element_data = {
            id = element._attr.id,
            lon = element._attr.lon,
            lat = element._attr.lat
        }

        if element.tag ~= nil then
            for _, tag in ipairs(element.tag) do
                extract_element_data_from_tag(element_data, tag, processed, defs, features)
            end

            if not element_has_features(element_data, features) then
                table.insert(processed.unknown_elements, element_data)
            end

            process_element_features(element_data, processed, defs, features)
        end

        if type == "node" then
            processed.nodes[element_data.id] = element_data
        elseif type == "way" then
            extract_childs_from_way(element_data, element, processed)
        elseif type == "relation" then
            extract_childs_from_relation(element_data, element, processed)
        end
    end
end

process_elements(xml_handler.root.osm.node, processed, defs, features, "node")
process_elements(xml_handler.root.osm.way, processed, defs, features, "way")
process_elements(xml_handler.root.osm.relation, processed, defs, features, "relation")

os.execute("mkdir -p " .. filename .. ".processed")

for _, feature in ipairs(features) do
    local count_filename = filename .. ".processed/" .. feature .. "s_count"
    local unknown_filename = filename .. ".processed/unknown_" .. feature .. "s"

    local count_file = io.open(count_filename, "wb")
    if not count_file then
        print("Unable to open output file \"" .. count_filename .. "\"")
        break
    end

    local unknown_file = io.open(unknown_filename, "wb")
    if not unknown_file then
        print("Unable to open output file \"" .. unknown_file .. "\"")
        break
    end

    for type, count in pairs(processed.feature_types[feature]) do
        count_file:write(type .. ": " .. count .. "\n")
    end
    for unknown, _ in pairs(processed.unknown_features[feature]) do
        unknown_file:write(unknown .. "\n")
    end

    count_file:close()
    unknown_file:close()
end

local out_file_unknown_tags = io.open(filename .. ".processed/unknown_tags", "wb")
if not out_file_unknown_tags then
    print("Unable to open output file \"" .. filename .. ".processed/unknown_tags\"")
    return 1
end
for tag, _ in pairs(processed.unknown_tags) do
    out_file_unknown_tags:write(tag .. "\n")
end
out_file_unknown_tags:close()

local out_file_unknown_elements = io.open(filename .. ".processed/unknown_elements", "wb")
if not out_file_unknown_elements then
    print("Unable to open output file \"" .. filename .. "_unknown_elements\"")
    return 1
end
for _, element in ipairs(processed.unknown_elements) do
    for k, v in pairs(element) do
        out_file_unknown_elements:write("key: " .. k .. ", value: " .. tostring(v) .. "\n")
    end
    out_file_unknown_elements:write("\n")
end
out_file_unknown_elements:close()
