return {
    ignored = {},
    properties = {
        aerodrome = {
            ["aerodrome:type"] = true,
            ["ele"] = true,
        },
        hangar = {},
        helipad = {},
        runway = {
            ["ele"] = true,
            ["incline"] = true,
            ["length"] = true,
            ["lit"] = true,
            ["lit:centre"] = true,
            ["surface"] = true,
            ["width"] = true,
        },
        taxiway = {
            ["crossing:aircraft"] = true,
            ["surface"] = true,
            ["width"] = true,
        },
        terminal = {
            ["entrance"] = true,
        },
    },
    swaps = {},
    swaps_to_properties = {},
}
