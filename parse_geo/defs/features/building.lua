return {
    ignored = {
        no = true, -- not needed
    },
    properties = {
        apartments = {
            ["flats"] = true,
            ["levels"] = true,
            ["material"] = true,
        },
        barn = {},
        cabin = {},
        church = {
            ["building:architecture"] = true,
            ["denomination"] = true,
            ["religion"] = true,
        },
        commercial = {},
        detached = {},
        fire_station = {},
        garage = {},
        government = {},
        hangar = {},
        hospital = {},
        hotel = {},
        house = {},
        hut = {},
        industrial = {},
        office = {},
        school = {
            ["levels"] = true,
        },
        residential = {
            ["levels"] = true,
        },
        ["residential;barn"] = {
            ["levels"] = true,
        },
        retail = {},
        roof = {},
        ruins = {
            ["ruins"] = true,
        },
        semidetached_house = {},
        service = {
            ["utility"] = true,
        },
        shed = {},
        static_caravan = {},
        warehouse = {},
        yes = {},
    },
    swaps = {
        ["residential;Barn"] = "residential;barn",
        ["yes;school"] = "school",
    },
    swaps_to_properties = {},
}
