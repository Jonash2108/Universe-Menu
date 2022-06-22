-------------------The place where the modification is strictly prohibited must be held accountable, please respect the author andlicense-------------------
----------------------I have obtained permission from the author to call the function during development
----------------------If you need a second change, contact the author yourself and the author's permission



---------------请梨落、21大人自行退场，像你们那么聪明的人是从来不会抄代码然后卖的对吧？
---------------未经允许调用/复制函数你死几个妈?


----------------base
function string:split(sep)
    local sep, fields = sep or "\t", {}
    local pattern = string.format("([^%s]+)", sep)
    self:gsub(pattern, function(c) fields[#fields+1] = c end)
    return fields
end
----------------split base

local function distanceTo(pid)
    local my_pos=player.get_player_coords(player.player_id())
    local er_pos=player.get_player_coords(pid)
    local distance=(my_pos.x-er_pos.x)+(my_pos.y-er_pos.y)+(my_pos.z-er_pos.z)
    return math.abs(distance)
end


local function intToIp(num)
    ip=''
    local int16=string.format("%x",num)
    for i=1,#int16 do
        if math.fmod(i,2)==0 then
            if ip~='' then
                ip=ip..'.'..var_int
            else
                ip=var_int
            end
        else
            var_int=tostring(tonumber(string.sub(int16,i,i+1), 16))
            --print(tostring(int16[i])..tostring(int16[i+1]))
        end
    end
    return ip
end

local anti_sync=player.add_modder_flag("Universe's Anti-Sync")

local main=menu.add_feature("Universe_SYS","parent",0)


_lastpos=v3(0,0,0)

local function is_player_move(pos)
    if pos.x==_lastpos.x and pos.y==_lastpos.y then
        return false
    else
        _lastpos=pos
        return true
    end
end




--------------Integrate other necessary LUA libraries (methods)---------------
local Myped = function()
    return player.get_player_ped(player.player_id())
end
local Pedshoot = function()
    return ped.is_ped_shooting(Myped()) and not player.is_player_in_any_vehicle(player.player_id()) or
        ped.get_vehicle_ped_is_using == 0 or
        ped.get_vehicle_ped_is_using == nil
end
local Pedweapon = function()
    return ped.get_current_ped_weapon(Myped())
end
local all_ped=ped.get_all_peds()

-----------------Host take functions from KEK‘s authorization--------------------
local script_event_hashes = {
    ["Netbail kick"] = 2092565704,
    ["Kick 1"] = 1964309656,
    ["Kick 2"] = 696123127,
    ["Kick 3"] = 43922647,
    ["Kick 4"] = 600486780,
    ["Kick 5"] = 1954846099,
    ["Kick 6"] = 153488394,
    ["Kick 7"] = 1249026189,
    ["Kick 8"] = 515799090,
    ["Kick 9"] = 1463355688,
    ["Kick 10"] = -1382676328,
    ["Kick 11"] = 1256866538,
    ["Kick 12"] = 515799090,
    ["Kick 13"] = -1813981910,
    ["Kick 14"] = 202252150,
    ["Kick 15"] = -19131151,
    ["Kick 16"] = -635501849,
    ["Kick 17"] = 1964309656,
    ["Crash 1"] = -988842806,
    ["Crash 2"] = -2043109205,
    ["Crash 3"] = 1926582096,
    ["Crash 4"] = 153488394,
    ["Script host crash 1"] = 315658550,
    ["Script host crash 2"] = -877212109,
    ["Disown personal vehicle"] = -2072214082,
    ["Vehicle EMP"] = 975723848,
    ["Destroy personal vehicle"] = 1229338575,
    ["Kick out of vehicle"] = -1005623606,
    ["Remove wanted level"] = 1187364773,
    ["Give OTR or ghost organization"] = -397188359,
    ["Block passive"] = 1472357458,
    ["Send to mission"] = -1147284669,
    ["Send to Perico island"] = -1479371259,
    ["Apartment invite"] = 1249026189,
    ["CEO ban"] = 1355230914,
    ["Dismiss or terminate from CEO"] = -316948135,
    ["Insurance notification"] = 299217086,
    ["Transaction error"] = -2041535807,
    ["CEO money"] = 1152266822,
    ["Bounty"] = -1906146218,
    ["Banner"] = 1659915470,
    ["Sound 1"] = 1537221257,
    ["Sound 2"] = -1162153263,
    ["Bribe authorities"] = -151720011
}	

function get_script_event_hash(name)
    local hash = script_event_hashes[name]
    if math.type(hash) == "integer" then
        return hash
    else
        return 0
    end

end

function generic_player_global(pid)
    return script.get_global_i(1630816 + (1 + (pid * 597) + 508))
end

local function get_people_in_front_of_person_in_host_queue()
    if network.network_is_host() then
        return {}, {}
    end
    local hosts, friends = {}, {}
    local player_host_priority = player.get_player_host_priority(player.player_id())
    for pid = 0, 31 do
        if player.is_player_valid(pid) and pid ~= player.player_id() then
            if player.get_player_host_priority(pid) <= player_host_priority or player.is_player_host(pid) then
                hosts[#hosts + 1] = pid
                if network.is_scid_friend(player.get_player_scid(pid)) then
                    friends[#friends + 1] = pid
                end
            end
        end
    end
    return hosts, friends
end

local SE_send_limiter = {}
function send_script_event(name, pid, args, friend_condition)
    if player.is_player_valid(pid) and pid ~= player.player_id() then
        if math.type(pid) == "integer" then 
            for i = 1, #args do
                if math.type(args[i]) ~= "integer" then
                    return
                end
            end
        else
            return
        end
        repeat
            local temp = {}
            for i = 1, #SE_send_limiter do
                if SE_send_limiter[i] > utils.time_ms() then
                    temp[#temp + 1] = SE_send_limiter[i]
                end
            end
            SE_send_limiter = temp
            if #temp >= 10 then
                system.yield(0)
            end
        until #temp < 10
        if player.is_player_valid(pid) then
            SE_send_limiter[#SE_send_limiter + 1] = utils.time_ms() + (1 // gameplay.get_frame_time())
            script.trigger_script_event(get_script_event_hash(name), pid, args)
        end
    else
        system.yield(0)
    end
end

local function get_host()
    local hosts = get_people_in_front_of_person_in_host_queue()
    for i, pid in pairs(hosts) do
        send_script_event("Netbail kick", pid, {pid, generic_player_global(pid)})
        for x=0,17 do
            send_script_event("Kick "..tostring(x), pid, {pid, generic_player_global(pid)})
        end
    end
    return {}, false
end

--------------------------------------------------------

---------------------mian-------------------------------

local main_self=menu.add_feature("Player options","parent",main.id)


local main_network=menu.add_feature("Online options","parent",main.id)


local Heist_Control=menu.add_feature("Task options","parent",main.id)


local main_weapon=menu.add_feature("Weapon options","parent",main.id)


local main_protect=menu.add_feature("Protection options","parent",main.id)


local main_vehicle_menu=menu.add_feature("Vehicle options","parent",main.id)


local main_options=menu.add_feature("Menu Settings","parent",main.id)










local main_about=menu.add_feature(
    "about",
    "action",
    main.id,
    function ()
    -----------------It is strictly forbidden to modify this----------------------------
        ui.notify_above_map("~b~Universe_SYS\nwelcomeUniverse v1.6\n2T Player QQ Group：872986398","welcomeUniverse",0)
        ui.notify_above_map("~b~Universe_SYS\nLua address\n~y~https://github.com/BaiXinSpuer/2T1_Universe","welcomeUniverse",0)
        --menu.notify('Internal beta users are prohibited from sharing any content about the test，Feedback/discuss on the beta version only in the beta channel','Universe Beta Warn',30)
    -----------------It is strictly forbidden to modify this---------------------------- 
end)
main_feedback=menu.add_feature(
    "Feedback/Questionnaire",
    'action',
    main.id,
    function()
        utils.to_clipboard('https://www.wjx.cn/vj/waB732w.aspx')
        menu.notify('It has been copied to the clipboard, please paste it to the browser to use','Universe',6,1)
        main_feedback.hidden=true
    end
)
main_discord=menu.add_feature(
    "Get DIS",
    'action',
    main.id,
    function()
        if main_discord.name=='Get DIS' then
            utils.to_clipboard('https://discord.gg/vef8NGZj7a')
        else
            utils.to_clipboard('872986398')
            main_discord.hidden=true
        end
        menu.notify('Copied to clipboard','Universe',6,1)
        main_discord.name='Get QQ'
    end
)


----------------------main_targets-------------------------------
local main_net_all=menu.add_feature("All player","parent",main_network.id)



local mission_cheat=menu.add_feature("Accessibility","parent",Heist_Control.id)


local main_title_info={
    "|",
    "|Θ",
    "U",
    "U|",
    "U||",
    "Un",
    "Un|",
    "Uni",
    "Uni||",
    "Uni",
    "Uni",
    "Uni\\",
    "Uni\\/",
    "Uni\\/",
    "Univ",
    "Univₑ",
    "Univₔ",
    "Unive",
    "Unive|",
    "Unive|}",
    "Univer",
    "Univer$",
    "Univer$^",
    "Univers",
    "Universₑ",
    "Universₔ",
    "Universe",
    "Universe-",
    "Universe_",
    "Universe_$",
    "Universe_$^",
    "Universe_S",
    "Universe_S\\",
    "Universe_S\\/",
    "Universe_S\\/|",
    "Universe_SY",
    "Universe_SY$",
    "Universe_SY$^",
    "Universe_SYS",
    "Universe_SYS",
    "Universe_SY$^",
    "Universe_SY$",
    "Universe_SY",
    "Universe_S\\/|",
    "Universe_S\\/",
    "Universe_S\\",
    "Universe_S",
    "Universe_$^",
    "Universe_$",
    "Universe_",
    "Universe-",
    "Universe",
    "Universₔ",
    "Universₑ",
    "Univers",
    "Univer$^",
    "Univer$",
    "Univer",
    "Unive|}",
    "Unive|",
    "Unive",
    "Univₔ",
    "Univₑ",
    "Univ",
    "Uni\\/",
    "Uni\\/",
    "Uni\\",
    "Uni",
    "Uni",
    "Uni||",
    "Uni",
    "Un|",
    "Un",
    "U||",
    "U|",
    "U",
    "|Θ",
    "|"
}
local main_title_nl={
    "|",
    "|\\",
    "|\\|",
    "N",
    "N3",
    "Ne",
    "Ne\\",
    "Ne\\/",
    "Nev",
    "Nev3",
    "Neve",
    "Neve|",
    "Neve|2",
    "Never|",
    "Neverl",
    "Neverl4",
    "Neverlo",
    "Neverlos|",
    "Neverlos|D",
    "Neverlos",
    "Neverlose",
    "Neverlose.",
    "Neverlose.<",
    "Neverlose.c",
    "Neverlose.c<",
    "Neverlose.cc",
    "Neverlose.cc",
    "Neverlose.c<",
    "Neverlose.c",
    "Neverlose.<",
    "Neverlose.",
    "Neverlose",
    "Neverlo|D",
    "Neverlo|",
    "Neverlo_",
    "Neverl4",
    "Nevelo",
    "Neverl_",
    "Never|",
    "Never_",
    "Neve|2",
    "Neve|",
    "Neve_",
    "Nev3",
    "Nev_",
    "Ne\\/",
    "Ne\\",
    "Ne_",
    "N3",
    "N_",
    "|\\|",
    "|\\",
    "|"
}

local main_title_sk={
        "             ga",
    "            gam",
    "           game",
    "          games",
    "         gamese",
    "        gamesen",
    "       gamesens",
    "      gamesense",
    "     gamesense ",
    "    gamesense  ",
    "   gamesense   ",
    "  gamesense    ",
    " gamesense     ",
    "gamesense      ",
    "gamesense      ",
    "gamesense      ",
    "gamesense      ",
    "amesense       ",
    "mesense        ",
    "esense         ",
    "sense          ",
    "ense           ",
    "nse            ",
    "se             ",
    "e              ",
    "                  "
}


local main_title_2T={
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    "1",
    "2",
    "2A",
    "2B",
    "2C",
    "2D",
    "2E",
    "2F",
    "2G",
    "2H",
    "2I",
    "2J",
    "2K",
    "2L",
    "2M",
    "2N",
    "2O",
    "2P",
    "2Q",
    "2R",
    "2S",
    "2T",
    "2U",
    "2V",
    "2W",
    "2X",
    "2Y",
    "2Z",
    "2A",
    "2B",
    "2C",
    "2D",
    "2E",
    "2F",
    "2G",
    "2H",
    "2I",
    "2J",
    "2K",
    "2L",
    "2M",
    "2N",
    "2O",
    "2P",
    "2Q",
    "2R",
    "2S",
    "2T",
    "2TA",
    "2TB",
    "2TC",
    "2TD",
    "2TE",
    "2TF",
    "2TG",
    "2TH",
    "2TI",
    "2TJ",
    "2TK",
    "2TL",
    "2TM",
    "2TN",
    "2TO",
    "2TP",
    "2TQ",
    "2TR",
    "2TS",
    "2TT",
    "2TU",
    "2TV",
    "2TW",
    "2TX",
    "2TY",
    "2TZ",
    "2TA",
    "2TAA",
    "2TAB",
    "2TAC",
    "2TAD",
    "2TAE",
    "2TAF",
    "2TAG",
    "2TAH",
    "2TAI",
    "2TAJ",
    "2TAK",
    "2TAL",
    "2TAM",
    "2TAN",
    "2TAO",
    "2TAP",
    "2TAQ",
    "2TAR",
    "2TAS",
    "2TAT",
    "2TAU",
    "2TAV",
    "2TAW",
    "2TAX",
    "2TAY",
    "2TAZ",
    "2TAA",
    "2TAB",
    "2TAC",
    "2TAD",
    "2TAE",
    "2TAF",
    "2TAG",
    "2TAH",
    "2TAI",
    "2TAJ",
    "2TAK",
    "2TAKA",
    "2TAKB",
    "2TAKC",
    "2TAKD",
    "2TAKE",
    "2TAKF",
    "2TAKG",
    "2TAKH",
    "2TAKI",
    "2TAKJ",
    "2TAKK",
    "2TAKL",
    "2TAKM",
    "2TAKN",
    "2TAKO",
    "2TAKP",
    "2TAKQ",
    "2TAKR",
    "2TAKS",
    "2TAKT",
    "2TAKU",
    "2TAKV",
    "2TAKW",
    "2TAKX",
    "2TAKY",
    "2TAKZ",
    "2TAKA",
    "2TAKB",
    "2TAKC",
    "2TAKD",
    "2TAKE",
    "2TAKE1",
    "2TAKE2",
    "2TAKE3",
    "2TAKE4",
    "2TAKE5",
    "2TAKE6",
    "2TAKE7",
    "2TAKE8",
    "2TAKE9",
    "2TAKE1",
    "2TAKE1",
    "2TAKE1",
    "2TAKE1",
    "2TAKE1",
    "2TAKE1",
    "2TAKE1",
    "2TAKE1",
    "2TAKE1",
    "2TAKE1",
    "2TAKZ",
    "2TAKY",
    "2TAKX",
    "2TAKW",
    "2TAKV",
    "2TAKU",
    "2TAKT",
    "2TAKS",
    "2TAKR",
    "2TAKQ",
    "2TAKP",
    "2TAKO",
    "2TAKN",
    "2TAKM",
    "2TAKL",
    "2TAKK",
    "2TAKJ",
    "2TAKI",
    "2TAKH",
    "2TAKG",
    "2TAKF",
    "2TAKE",
    "2TAKD",
    "2TAKC",
    "2TAKB",
    "2TAKA",
    "2TAZ",
    "2TAY",
    "2TAX",
    "2TAW",
    "2TAV",
    "2TAU",
    "2TAT",
    "2TAS",
    "2TAR",
    "2TAQ",
    "2TAP",
    "2TAO",
    "2TAN",
    "2TAM",
    "2TAL",
    "2TAK",
    "2TAJ",
    "2TAI",
    "2TAH",
    "2TAG",
    "2TAF",
    "2TAE",
    "2TAD",
    "2TAC",
    "2TAB",
    "2TAA",
    "2TZ",
    "2TY",
    "2TX",
    "2TW",
    "2TV",
    "2TU",
    "2TT",
    "2TS",
    "2TR",
    "2TQ",
    "2TP",
    "2TO",
    "2TN",
    "2TM",
    "2TL",
    "2TK",
    "2TJ",
    "2TI",
    "2TH",
    "2TG",
    "2TF",
    "2TE",
    "2TD",
    "2TC",
    "2TB",
    "2TA",
    "2Z",
    "2Y",
    "2X",
    "2W",
    "2V",
    "2U",
    "2T",
    "2S",
    "2R",
    "2Q",
    "2P",
    "2O",
    "2N",
    "2M",
    "2L",
    "2K",
    "2J",
    "2I",
    "2H",
    "2G",
    "2F",
    "2E",
    "2D",
    "2C",
    "2B",
    "2A",
    "9",
    "8",
    "7",
    "6",
    "5",
    "4",
    "3",
    "2",
    "1",
    "2",
    "2T",
    "2TA",
    "2TAK",
    "2TAKE",
    "2TAKE1",
    "2TAKE1 ",
    "2TAKE1 Y",
    "2TAKE1 YY",
    "2TAKE1 YYD",
    "2TAKE1 YYDS",
    "2TAKE1 YYDS",
    "2TAKE1 YYDS",
    "2TAKE1 YYDS",
    "           ",
    "2TAKE1 YYDS",
    "2TAKE1 YYDS",
    "2TAKE1 YYDS",
    "2TAKE1 YYDS",
    "           ",
    "2TAKE1 YYDS",
    "2TAKE1 YYDS",
    "2TAKE1 YYDS",
    "2TAKE1 YYDS",
    "           ",
    "2TAKE1 YYDS",
    "2TAKE1 YYDS",
    "2TAKE1 YYDS",
    "2TAKE1 YYDS",
    "           ",
    "2TAKE1 YYDS",
    "2TAKE1 YYDS",
    "2TAKE1 YYDS",
    "2TAKE1 YYDS",
    "2TAKE1 YYDS",
    "2TAKE1 YYDS",
    "2TAKE1 YYDS",
    "2TAKE1 YYDS",
    "           ",
    "2TAKE1 YYDS",
    "2TAKE1 YYDS",
    "2TAKE1 YYDS",
    "2TAKE1 YYDS",
    "           ",
    "2TAKE1 YYDS",
    "2TAKE1 YYDS",
    "2TAKE1 YYDS",
    "2TAKE1 YYDS",
    "           ",
    "2TAKE1 YYDS",
    "2TAKE1 YYDS",
    "2TAKE1 YYDS",
    "2TAKE1 YYDS",
    "           ",
    "2TAKE1 YYDS",
    "2TAKE1 YYDS",
    "2TAKE1 YYDS",
    "2TAKE1 YYDS",
    "2TAKE1 YYD",
    "2TAKE1 YY",
    "2TAKE1 Y",
    "2TAKE1",
    "2TAKE",
    "2TAK",
    "2TA",
    "2T",
    "2"
}
----------------------------on_start----------------------------
_U_main_title=menu.add_feature(
    "Dynamic name",
    "value_str",
    main_options.id,
    function(a)
        while a.on do
            system.yield(0)
            if a.on then
                if a.value==0 then
                    for i=1, #main_title_info do
                        if a.on then
                            main.name=main_title_info[i]
                            system.yield(100)
                        else
                            main.name='Universe_SYS'
                        end
                    end
                elseif a.value==1 then
                    for i=1, #main_title_nl do
                        if a.on then
                            main.name=main_title_nl[i]
                            system.yield(150)
                        else
                            main.name='Universe_SYS'
                        end
                    end
                elseif a.value==2 then
                    for i=1, #main_title_sk do
                        if a.on then
                            main.name=main_title_sk[i]
                            system.yield(300)
                        else
                            main.name='Universe_SYS'
                        end
                    end
                elseif a.value==3 then
                    for i=1, #main_title_2T do
                        if a.on then
                            main.name=main_title_2T[i]
                            system.yield(10)
                        else
                            main.name='Universe_SYS'
                        end
                    end
                end
            else
                main.name='Universe_SYS'
            end
        end
    end
)
_U_main_title:set_str_data({
    "Universe_SYS",
    "NeverLose",
    "Gamesense",
    "2Take1"
})


_U_main_title.threaded=true


local function show_info_name(pid,name,pos,r,g,b,reason)
    if player.is_player_host(pid) then
        name=name..'[H]'
    end
    if script.get_host_of_this_script()==pid then
        name=name..'[S]'
    end
    if interior.get_interior_from_entity(player.get_player_ped(pid))~=0 then
        name=name..'[I]'
    end
    if player.get_player_wanted_level(pid)~=0 then
        if r==255 and g==255 and b==255 then
            r,g,b=159,197,232
        end
        name=name..'['..tostring(player.get_player_wanted_level(pid))..'星]'
    end
    if reason then
        name=name..'['..tostring(reason)..']'
        len_name=#name/2
    end
    ui.draw_rect(0.001, 0.999, 4.5, 0.085, 0, 0, 0, 0)
    ui.set_text_color(r, g, b, 255)				
    ui.set_text_scale(0.35)
    ui.set_text_font(0)
    ui.set_text_centre(true)
    ui.set_text_outline(true)
    ui.draw_text(name,pos)
    return len_name*0.015
end



_U_title_players=menu.add_feature(
    "Player list",
    "toggle",
    main_options.id,
    function(a)
        while a.on do
            system.yield(0)
            if not _U_fuck_myself.on and not _U_fuck_them.on then
                now_pos=v2(0,0)
                for pid=0,31 do
                    if player.is_player_valid(pid) then
                        local player_name=player.get_player_name(pid) --名字
                        local is_modder_MANUAL=player.is_player_modder(pid,1 << 0x00) -- 科技 手动
                        local is_modder_PLAYER_MODEL=player.is_player_modder(pid,1 << 0x01) -- 科技 修改模型
                        local is_modder_SCID_SPOOF=player.is_player_modder(pid,1 << 0x02) -- 科技 Rid欺骗
                        local is_modder_INVALID_OBJECT_CRASH=player.is_player_modder(pid,1 << 0x03) -- 科技 无效物品
                        local is_modder_INVALID_PED_CRASH=player.is_player_modder(pid,1 << 0x04) -- 科技 无效实体
                        local is_modder_MODEL_CHANGE_CRASH=player.is_player_modder(pid,1 << 0x05) -- 科技 修改模型崩溃
                        local is_modder_PLAYER_MODEL_CHANGE=player.is_player_modder(pid,1 << 0x06) -- 科技 玩家模型修改
                        local is_modder_RAC=player.is_player_modder(pid,1 << 0x07) -- 科技 IMP
                        local is_modder_SYNC_CRASH=player.is_player_modder(pid,1 << 0x0D) -- 科技 同步崩溃
                        local is_modder_NET_EVENT_CRASH =player.is_player_modder(pid,1 << 0x0E) -- 科技 网络事件崩溃
                        local is_modder_HOST_TOKEN=player.is_player_modder(pid,1 << 0x10) -- 科技 主机令牌
                        local is_modder_INVALID_VEHICLE=player.is_player_modder(pid,1 << 0x11) -- 科技 无效载具
                        local is_modder_FRAME_FLAGS=player.is_player_modder(pid,1 << 0x12) -- 科技 小助手
                        local is_god=player.is_player_god(pid) --无敌
                        local is_frd=player.is_player_friend(pid) --好友
                        if player_name then
                            local len_name=#player_name*0.01
                        else
                            local len_name=0
                        end
                        local is_veh_god=player.is_player_vehicle_god(pid) --车无敌
                        if now_pos==v2(0,0) then
                            now_pos=v2(len_name/2,0)
                        elseif now_pos.x+len_name-0.012<=1 then
                            pass()
                        else
                            now_pos=v2(len_name/2,now_pos.y+0.03)
                        end
                        if is_frd then
                            len_name=show_info_name(pid,player_name,now_pos,100,0,200) --蓝色
                        elseif is_modder_MANUAL then
                            len_name=show_info_name(pid,player_name,now_pos,255,255,0,'Manually mark') -- 黄色
                        elseif is_modder_SCID_SPOOF or is_modder_HOST_TOKEN then
                            len_name=show_info_name(pid,player_name,now_pos,65,232,79,'ID/Token spoof') --亮绿
                        elseif is_modder_RAC or is_modder_FRAME_FLAGS then
                            len_name=show_info_name(pid,player_name,now_pos,230,5,250,'Imp/KID') --粉色
                        elseif is_modder_PLAYER_MODEL or is_modder_INVALID_OBJECT_CRASH or is_modder_INVALID_PED_CRASH or is_modder_NET_EVENT_CRASH or is_modder_INVALID_VEHICLE or is_modder_MODEL_CHANGE_CRASH or is_modder_PLAYER_MODEL_CHANGE then
                            len_name=show_info_name(pid,player_name,now_pos,255,0,0,'danger') --红色
                        elseif is_god then
                            len_name=show_info_name(pid,player_name,now_pos,250,125,5,'Invincible') --橙色
                        elseif is_veh_god then
                            len_name=show_info_name(pid,player_name,now_pos,191,0,255,'Vehicle invincibility') --紫色
                        else
                            len_name=show_info_name(pid,player_name,now_pos,255,255,255) --白色
                        end
                        now_pos=now_pos+v2(len_name,0)
                    end
                end
            end
        end
    end
)

_U_title_players.threaded=true


local on_start_text=menu.add_feature(
    "This is invisible to you",
    "toggle",
    main.id,
    function(a)
        local i=0
        
        while a.on do
            system.yield(0)
            ui.set_text_color(i*10,i*2,100-i, 255)				
            ui.set_text_scale(1)
            ui.set_text_font(0)
            ui.set_text_centre(true)
            ui.set_text_outline(true)
            ui.draw_text("welcome\nUniverse",v2(0.5,0.3))
            i=i+10
        end
    end
)
on_start_text.hidden=true
on_start_text.threaded=true
local skills={
    "Kill others",
    "Drop.money",
    "Earn money",
    "Friendly",
    "Keep alive",
    "Crash",
    "Kick",
    "Hack the hack",
    "Abuse",
    "Heist",
    "Casino Heist"
}


local on_start_end=menu.add_feature(
    "This is invisible to you",
    "toggle",
    main.id,
    function(a)
        local month=os.date("%m")
        local today=os.date("%d")
        local date=month..'night'..today..'day'
        local i=255
        local x=0
        local randomthing=math.random(1,#skills)
        _U_main_title.on=true
        while a.on and i>0 do
            system.yield(0)
            ui.set_text_color(100-x,x*10, x*10, i)					
            ui.set_text_scale(1)
            ui.set_text_font(0)
            ui.set_text_centre(true)
            ui.set_text_outline(true)
            ui.draw_text("welcome\nUniverse\nToday is"..date..'\nsuitable'..skills[randomthing],v2(0.5,0.3))
            i=i-1
            x=x+1
        end
    end
)
on_start_end.hidden=true
on_start_end.threaded=true
local on_start=menu.add_feature(
    "This is invisible to you",
    "action",
    main.id,
    function()
        local me=player.player_id()
        local my_ped=player.get_player_ped(me)
        time.set_clock_time(23, 0, 0)
        entity.set_entity_coords_no_offset(my_ped, v3(-75.392, -819.27, 326.175))
        on_start_text.on=true
        graphics.set_next_ptfx_asset("scr_trevor1")
        while not graphics.has_named_ptfx_asset_loaded("scr_trevor1") do
            graphics.request_named_ptfx_asset("scr_trevor1")
            system.wait(0)
        end
        system.wait(4000)
        graphics.set_next_ptfx_asset("scr_trevor1")
        while not graphics.has_named_ptfx_asset_loaded("scr_trevor1") do
            graphics.request_named_ptfx_asset("scr_trevor1")
            system.wait(0)
        end
        graphics.start_ptfx_looped_on_entity("scr_trev1_trailer_boosh", my_ped, v3(0, 0.0, 0.0), v3(0, 0, 0), 2)
        system.wait(1)
        fire.add_explosion(v3(-50, -819.27, 326.175), 0, true, false, 0, my_ped)
        system.wait(1)
        time.set_clock_time(12, 0, 0)
        on_start_text.on=false
        on_start_end.on=true
        system.wait(4000)
        on_start_end.on=false
    end
)
on_start.hidden=true

--------------------toggle_targets------------------------------

------------Self option------------------
--------------Hide yourself on the map Done----------------
local ranbow={
    '#FF0000', '#FF0014', '#FF0028', '#FF003C', '#FF0050', '#FF0064', '#FF0078', '#FF008C', '#FF00A0',
    '#FF00B4', '#FF00C8', '#FF00DC', '#FF00F0', '#F000FF', '#DC00FF', '#C800FF', '#B400FF', '#A000FF', '#8C00FF', '#7800FF', '#6400FF', '#5000FF',
    '#3C00FF', '#2800FF', '#1400FF', '#0000FF', '#0000FF', '#0014FF', '#0028FF', '#003CFF', '#0050FF', '#0064FF', '#0078FF', '#008CFF', '#00A0FF', '#00B4FF',
    '#00C8FF', '#00DCFF', '#00F0FF', '#00FFF0', '#00FFDC', '#00FFC8', '#00FFB4', '#00FFA0', '#00FF8C', '#00FF78', '#00FF64', '#00FF50', '#00FF3C', '#00FF28', '#00FF14',
    '#00FF00', '#00FF00', '#14FF00', '#28FF00', '#3CFF00', '#50FF00', '#64FF00', '#78FF00', '#8CFF00', '#A0FF00', '#B4FF00', '#C8FF00', '#DCFF00', '#F0FF00', '#FFFF00', '#FFF000',
    '#FFDC00', '#FFC800', '#FFB400', '#FFA000', '#FF8C00', '#FF7800', '#FF6400', '#FF5000', '#FF3C00', '#FF2800', '#FF1400'
}




_U_health_cheat=menu.add_feature(
    "Hide yourself on the map"
    ,"toggle",
    main_self.id,
    function(a)
        while a.on do
            system.yield(0)
            if a.on then
                local me = player.player_id()
                local myid = player.get_player_ped(me)
                ped.set_ped_max_health(myid,0)
                ped.set_ped_health(myid,1000)
            else
                local me = player.player_id()
                local myid = player.get_player_ped(me)
                ped.set_ped_max_health(myid,328)
                ped.set_ped_health(myid,328)
            end
        end
    end
)


local show__U_time_go_back_info=menu.add_feature(
    "This is a display",
    "toggle",
    main_self.id,
    function(a)
        r,g,b=math.random(0,255),math.random(0,255), math.random(0,255)
        while a.on do
            system.yield(0)
            if a.on then 
                ui.set_text_color(r,g,b, 185)					
                ui.set_text_scale(0.55)
                ui.set_text_font(0)
                ui.set_text_centre(true)
                ui.set_text_outline(true)
                ui.draw_text("You have turned on time jump\nJumping in time\nYou need to keep teleporting between two locations",v2(0.5,0.3))
            end
        end
    end
)

local show__U_time_go_back_info2=menu.add_feature(
    "This is a display",
    "toggle",
    main_self.id,
    function(a)
        r,g,b=math.random(0,255),math.random(0,255), math.random(0,255)
        while a.on do
            system.yield(0)
            if a.on then
                ui.set_text_color(r,g,b, 185)					
                ui.set_text_scale(0.55)
                ui.set_text_font(0)
                ui.set_text_centre(true)
                ui.set_text_outline(true)
                ui.draw_text("Each transmission interval is 15S\nYou can bring a vehicle for time warp\nWill start in 8 seconds",v2(0.5,0.5))
            end
        end
    end
)
show__U_time_go_back_info.hidden=true
show__U_time_go_back_info2.hidden=true
show__U_time_go_back_info.threaded=true
show__U_time_go_back_info2.threaded=true
_U_time_go_back=menu.add_feature(
    "Time jump",
    "toggle",
    main_self.id,
    function(a)
        local me = player.player_id()
        local new_pos=player.get_player_coords(me)
        last_pos=new_pos
        while a.on do
            local me = player.player_id()
            local my_ped=player.get_player_ped(me)
            if a.on then
                ui.notify_above_map("~r~Attention!\nThe time jump has begun! !","Universe",6)
            end
            system.yield(5000)
            if a.on then
                ui.notify_above_map("~r~Attention!\nThe time jump has begun! !","Universe",6)
            end
            system.yield(5000)
            if a.on then
                ui.notify_above_map("~r~Attention!\nThe time jump has begun! !","Universe",6)
            end
            system.yield(5000)
            if a.on then
                local new_pos=player.get_player_coords(me)
                if player.is_player_in_any_vehicle(me) then
                    entity.set_entity_coords_no_offset(player.get_player_vehicle(me),last_pos)
                else
                    entity.set_entity_coords_no_offset(my_ped,last_pos)
                end
                last_pos=new_pos
            end
        end
    end
)
_U_time_go_back.hidden=true



_U_time_go_back2=menu.add_feature(
    "Time jump",
    "toggle",
    main_self.id,
    function(a)
        if a.on then
            show__U_time_go_back_info.on=true
            show__U_time_go_back_info2.on=true
            system.yield(8000)
            if a.on then
                show__U_time_go_back_info.on=false
                show__U_time_go_back_info2.on=false
                _U_time_go_back.on=true
            else
                show__U_time_go_back_info2.on=false
                show__U_time_go_back_info.on=false
                _U_time_go_back.on=false
            end
        else
            show__U_time_go_back_info2.on=false
            show__U_time_go_back_info.on=false
            _U_time_go_back.on=false
        end
    end
)


_U_ghost_fucker=menu.add_feature(
    "Ghost crash",
    "toggle",
    main_self.id,
    function(a)
        if a.on then
            ghost_veh_c={}
            for i=0,180 do
                --local veh=vehicle.create_vehicle(1394036463,player.get_player_coords(player.player_id())+v3(0,0,5),0,true,true)
                local veh=object.create_object(3026699584,player.get_player_coords(player.player_id())+v3(0,0,5),true,true)
                ghost_veh_c[#ghost_veh_c+1]=veh
                entity.attach_entity_to_entity(veh,player.get_player_ped(player.player_id()),0,v3(0,0,0),v3(0,0,0),true,false,true,0,true)
                entity.set_entity_visible(veh,false)
            end
        else
            if ghost_veh_c then
                for i=1,#ghost_veh_c do
                    entity.delete_entity(ghost_veh_c[i])
                end
            end
        end
    end

)
_U_ghost_fucker.hidden=true
-----------Online players---------------


-----------Host take Done--------------

_U_get_host=menu.add_feature(
    "Host take",
    "toggle",
    main_network.id,
    function(a)
        while a.on and not network.network_is_host() do
            system.yield(0)
				local nothing, friends = get_host()
				if friends then
					break
				end
		end
    end


)
------------------watch dog
_U_active_watch_dog=menu.add_feature(
    "Watchdog analysis",
    'toggle',
    main_network.id,
    function(a)
        while a.on do
            system.yield(0)
            if controls.get_control_normal(0,114)==1.0 then
                local aim_ent=player.get_entity_player_is_aiming_at(player.player_id())
                if controls.get_control_normal(0,183)==1.0 then
                    fire.add_explosion(entity.get_entity_coords(aim_ent),0, true, false, 0,player.get_player_ped(player.player_id()))
                elseif controls.get_control_normal(0,26)==1.0 and not ped.is_ped_a_player(aim_ent) then
                    entity.freeze_entity(aim_ent,true)
                end
                if entity.is_entity_a_ped(aim_ent) and not ped.is_ped_a_player(aim_ent) then
                    if ped.is_ped_in_any_vehicle(aim_ent) then
                        if controls.get_control_normal(0,49)==1.0 then
                            fuck_NPC_car(aim_ent)
                        elseif controls.get_control_normal(0,0)==1.0 then
                            entity.delete_entity(ped.get_vehicle_ped_is_using(aim_ent))
                        elseif controls.get_control_normal(0,252)==1.0 then
                            vehicle.set_vehicle_forward_speed(ped.get_vehicle_ped_is_using(aim_ent),50)
                        elseif controls.get_control_normal(0,46)==1.0 then
                            vehicle.set_vehicle_forward_speed(ped.get_vehicle_ped_is_using(aim_ent),-50) 
                        end
                    end
                    if controls.get_control_normal(0,49)==1.0 then
                        entity.delete_entity(aim_ent)
                    elseif controls.get_control_normal(0,46)==1.0 then
                        ped.set_ped_health(aim_ent,0)
                    end
                elseif entity.is_entity_a_vehicle(aim_ent) then
                    if controls.get_control_normal(0,49)==1.0 then
                        ped.set_ped_into_vehicle(player.get_player_ped(player.player_id()),aim_ent,-1)
                    elseif controls.get_control_normal(0,0)==1.0 then
                        entity.delete_entity(aim_ent)
                    elseif controls.get_control_normal(0,252)==1.0 then
                        vehicle.set_vehicle_forward_speed(aim_ent,50)
                    elseif controls.get_control_normal(0,46)==1.0 then
                        vehicle.set_vehicle_forward_speed(aim_ent,-50) 
                    end
                elseif entity.is_entity_a_ped(aim_ent) and ped.is_ped_a_player(aim_ent) then
                    if ped.is_ped_in_any_vehicle(aim_ent) then
                        if controls.get_control_normal(0,49)==1.0 then
                            fuck_Player_car(aim_ent)
                        elseif controls.get_control_normal(0,0)==1.0 then
                            entity.delete_entity(ped.get_vehicle_ped_is_using(aim_ent))
                        elseif controls.get_control_normal(0,252)==1.0 then
                            vehicle.set_vehicle_forward_speed(ped.get_vehicle_ped_is_using(aim_ent),50)
                        elseif controls.get_control_normal(0,46)==1.0 then
                            vehicle.set_vehicle_forward_speed(ped.get_vehicle_ped_is_using(aim_ent),-50) 
                        end
                    end
                    if controls.get_control_normal(0,26)==1.0 then
                        ped.clear_ped_tasks_immediately(aim_ent)
                    end
                end
            elseif player.is_player_in_any_vehicle(player.player_id()) then
                if controls.get_control_normal(0,252)==1.0 then
                    vehicle.set_vehicle_forward_speed(player.get_player_vehicle(player.player_id()),50)
                elseif controls.get_control_normal(0,46)==1.0 then
                    vehicle.set_vehicle_forward_speed(player.get_player_vehicle(player.player_id()),entity.get_entity_speed(player.get_player_vehicle(player.player_id()))+200)
                end
            end
            if _U_watch_dog.on then
                pass()
            else
                _U_active_watch_dog.on=false
            end
        end
    end
)

_U_active_watch_dog.hidden=true
_U_active_watch_dog.threaded=true

function show____ped(aim_ent)
    if ped.is_ped_in_any_vehicle(aim_ent) then
        ui.draw_rect(0.001, 0.999, 4.5, 0.085, 0, 0, 0, 0)
        ui.set_text_color(255, 255, 0, 255)				
        ui.set_text_scale(0.5)
        ui.set_text_font(0)
        ui.set_text_centre(true)
        ui.set_text_outline(true)
        ui.draw_text('G:explode C:freeze V:delete X:accelerate E:Reversing F:boarding ',v2(0.5,0.96))
    elseif ped.is_ped_a_player(aim_ent) then
        ui.draw_rect(0.001, 0.999, 4.5, 0.085, 0, 0, 0, 0)
        ui.set_text_color(255, 255, 0, 255)				
        ui.set_text_scale(0.5)
        ui.set_text_font(0)
        ui.set_text_centre(true)
        ui.set_text_outline(true)
        ui.draw_text('G:explode C:freeze',v2(0.5,0.96))
    else
        ui.draw_rect(0.001, 0.999, 4.5, 0.085, 0, 0, 0, 0)
        ui.set_text_color(255, 255, 0, 255)				
        ui.set_text_scale(0.5)
        ui.set_text_font(0)
        ui.set_text_centre(true)
        ui.set_text_outline(true)
        ui.draw_text('G:explode C:freeze F:delete E:Kill',v2(0.5,0.96))
    end
end


function show____veh(aim_ent)
    ui.draw_rect(0.001, 0.999, 4.5, 0.085, 0, 0, 0, 0)
    ui.set_text_color(255, 255, 0, 255)				
    ui.set_text_scale(0.5)
    ui.set_text_font(0)
    ui.set_text_centre(true)
    ui.set_text_outline(true)
    ui.draw_text('G:explode C:freeze Z:delete X:accelerate E:Reversing F:boarding',v2(0.5,0.96))
end


function _U_Show(aim_ent)
    if entity.is_entity_a_ped(aim_ent) then
        show____ped(aim_ent)
    elseif entity.is_entity_a_vehicle(aim_ent) then
        show____veh(aim_ent)
    end
end


_U_watch_dog=menu.add_feature(
    "Watchdog mode",
    'toggle',
    main_network.id,
    function(a)
        if a.on then
            _U_active_watch_dog.on=true
            menu.notify('Right click to use\nPlease do not use in the air\nUse in the air may cause a crash','Universe',10)
            while a.on do
                system.yield(0)
                ui.show_hud_component_this_frame(14)
                while controls.get_control_normal(0,114)==1.0 do
                    system.yield(0)
                    local aim_ent=player.get_entity_player_is_aiming_at(player.player_id())
                    if aim_ent then
                        _U_Show(aim_ent)
                    end
                end
                if player.is_player_in_any_vehicle(player.player_id()) then
                    ui.draw_rect(0.001, 0.999, 4.5, 0.085, 0, 0, 0, 0)
                    ui.set_text_color(255, 255, 0, 255)				
                    ui.set_text_scale(0.5)
                    ui.set_text_font(0)
                    ui.set_text_centre(true)
                    ui.set_text_outline(true)
                    ui.draw_text('X:accelerate E:Supper accelerate',v2(0.5,0.96))
                end
            end
        else
            _U_active_watch_dog.on=false
        end
        
    end
)

------------------watch dog end

_U_fix_walk_on_water=menu.add_feature(
    'Repair water walking',
    'toggle',
    main_self.id,
    function()
        menu.notify('If water walking doesnt work, use it','Universe',2,4)
    end
)


objs={}
_U_walk_on_water=menu.add_feature(
    'Walking on water',
    'toggle',
    main_self.id,
    function(a)
        while a.on do
            system.yield(0)
            if entity.is_entity_in_water(player.get_player_ped(player.player_id())) and is_player_move(player.get_player_coords(player.player_id())) and _U_fix_walk_on_water.on then
                local obj=object.create_world_object(110106994,player.get_player_coords(player.player_id())-v3(0,0,1.25),true,true)
                system.yield(0)
                entity.set_entity_visible(obj,false)
                objs[#objs+1]=obj
                if #objs>=30 then
                    for obj=1,#objs do
                        entity.delete_entity(objs[obj])
                    end
                    objs={}
                end
            elseif entity.is_entity_in_water(player.get_player_ped(player.player_id())) and is_player_move(player.get_player_coords(player.player_id()))then
                local obj=object.create_world_object(110106994,player.get_player_coords(player.player_id())-v3(0,0,1.25),true,true)
                entity.set_entity_visible(obj,false)
                objs[#objs+1]=obj
                if #objs>=30 then
                    for obj=1,#objs do
                        entity.delete_entity(objs[obj])
                    end
                    objs={}
                end
            else
                if objs[2] then
                    for obj=1,#objs-1 do
                        entity.delete_entity(objs[obj])
                    end
                    objs={}
                end
            end
            if not a.on then
                if objs[1] then
                    for obj=1,#objs do
                        entity.delete_entity(objs[obj])
                    end
                    objs={}
                end
            end
        end
    end
)


_U_fire_fist=menu.add_feature(
    "Flame fist",
    "toggle",
    main_self.id,
    function(a)
        menu.notify("Press and hold the right button to accumulate power，Left click to use","Universe",2,4)
        while a.on do
            local max_time=20
            system.yield(0)
            if not player.is_player_in_any_vehicle(player.player_id()) then
                if ped.get_current_ped_weapon(player.get_player_ped(player.player_id()))==2725352035 then
                    if controls.get_control_normal(0,142)==1.0 and xuli_time~=0 then
                        for i=1,xuli_time do
                            local pos = player.get_player_coords(player.player_id())
                            for c=9,15,0.1 do
                                dir = cam.get_gameplay_cam_rot()
                                dir:transformRotToDir()
                                dir = dir * i*c
                                pos = pos + dir
                                fire.add_explosion(pos,29,true,false,0,player.get_player_ped(player.player_id()))
                            end
                        end
                        xuli_time=0
                        system.yield(1000)
                    elseif controls.get_control_normal(0,114)==1.0 and controls.get_control_normal(0,143)==0.0 then
                        if xuli_time==max_time-1 then
                            fire.add_explosion(player.get_player_coords(player.player_id())-v3(0,0,2),38,true,false,0,player.get_player_ped(player.player_id()))
                            xuli_time=xuli_time+1
                            system.yield(1000-(20-xuli_time)*50)
                        elseif xuli_time<max_time then
                            fire.add_explosion(player.get_player_coords(player.player_id())-v3(0,0,5),24,true,false,0,player.get_player_ped(player.player_id()))
                            xuli_time=xuli_time+1
                            system.yield(1000-(20-xuli_time)*50)
                        end
                    elseif controls.get_control_normal(0,114)==1.0 then
                        pass()
                    else
                        xuli_time=0
                    end
                    ui.show_hud_component_this_frame(14)
                end
            end
        end
    end
)


_U_fire_fist.threaded=true









-------------Host detection Done--------------

_U_is_host=menu.add_feature(
    "Become a host notification",
    "toggle",
    main_network.id,
    function(a)
        while a.on do
            system.yield(0)
            if network.network_is_host() then
                ui.set_text_color(255, 0, 155, 255)					
                    ui.set_text_scale(0.5)
                    ui.set_text_font(0)
                    ui.set_text_centre(true)
                    ui.set_text_outline(true)
                    ui.draw_text("Host mode",v2(0.95,0.96))
            end
        end
    end
)


---------------Kick player Done-------------------
_U_kick=menu.add_feature(
    "Host kick",
    "toggle",
    main_net_all.id,
    function(a)
        while a.on do
            system.yield(0)
            local me=player.player_id()
            for pid =0,31 do
                if pid ~= me and not player.is_player_friend(pid) then
                    network.network_session_kick_player(pid)
                end
            end
        end
    end

)

local sms_list={
    -- "fuck u",
    -- "qwertyuioplkjghsazxcvbnm",
    -- "abcdefg",
    -- "bitch",
    "操你妈",
    "不会吧不会吧，不会真的还有人没有2Take1吧？",
    "不会吧不会吧，不会真的还有人的外挂不支持脚本吧？",
    "祖安大舞台，有妈你就来",
    "生活中总能遇到奇葩的人或事",
    "就连打一局游戏，遇到的队友也是坑的一批",
    "时常被气得忍不住想口吐芬芳，比如现在，操你妈",
    "您真是莎士比亚去个士字",
    "我看您是新型冠状癞蛤蟆跳悬崖，想装蝙蝠侠？",
    "您打字这速度，是在查新华字典吗？",
    "对不起啊，我没有资格骂你神经病，毕竟我不是兽医",
    "百度搜不到您，搜狗一下就找到了",
    "巴黎圣母院烧了您没地方住了是吧",
    "凭你的智商可以过一辈子的六一",
    "我走我的阳关道，您过您的奈何桥",
    "您就是国家素质教育的漏网之鱼吧",
    "还好您不在上海，不然真不知道要把您分到哪里去",
    "我已经三天没吃饭了，但看到您的行为还是忍不住想吐",
    "您真是上帝造人用的草稿",
    "妹妹的腮红够不够？要不要你爹的巴掌凑",
    "你不讨厌，可是毫无用处。——钱钟书",
    "您脑子里的水倒出来是不是当初冲了龙王庙又漫了金山",
    "快把手腾出来吧，别用脚玩了",
    "我跟你们打游戏就是逛菜市场，各种菜",
    "你已被封禁",
}


------------骚扰玩家
_U_sms_cheat=menu.add_feature(
    "SMS",
    "toggle",
    main_net_all.id,
    function(a)
        while a.on do
            system.yield(0)
            local me=player.player_id()
            for pid =0,31 do
                if pid ~= me then
                    player.send_player_sms(pid,sms_list[math.random(1,#sms_list)])
                end
            end
        end
    end

)



-------------------反载具

local Anti_Vehicle=menu.add_feature(
    "Prohibited vehicles",
    "parent",
    main_net_all.id
)

local function Anti_Vehicle_Func(veh,anti_veh,pid,name)
    if entity.get_entity_model_hash(veh)==anti_veh then
        ped.clear_ped_tasks_immediately(player.get_player_ped(pid))
        menu.notify("Illegal vehicle detected"..name.."user："..player.get_player_name(pid),"Universe",3)
    end
end


_U_Anti_MK2=menu.add_feature(
    "Anti MK2",
    "toggle",
    Anti_Vehicle.id,
    function(a)
        while a.on do
            system.yield(0)
            for pid=0,31 do
                if player.is_player_vaild(pid) and player.is_player_in_any_vehicle(pid) then
                    Anti_Vehicle_Func(player.get_player_vehicle(pid),2069146067,pid,"MK2")
                end
            end
        end
    end
)
_U_Anti_MK1=menu.add_feature(
    "Anti MK1",
    "toggle",
    Anti_Vehicle.id,
    function(a)
        while a.on do
            system.yield(0)
            for pid=0,31 do
                if player.is_player_vaild(pid) and player.is_player_in_any_vehicle(pid) then
                    Anti_Vehicle_Func(player.get_player_vehicle(pid),884483972,pid,"MK1")
                end
            end
        end
    end
)

----------------Anti-vehicle





-----------------Violently kick Done-----------------
_U_force_kick=menu.add_feature(
    "Violently kick",
    "toggle",
    main_net_all.id,
    function(a)
        while a.on do
            system.yield(0)
            local me=player.player_id()
            for pid=0,31 do
                if pid~=me and not player.is_player_friend(pid) and player.is_player_valid(pid) then
                    network.network_session_kick_player(pid)
                    send_script_event("Netbail kick", pid, {pid, generic_player_global(pid)})
                    for x=0,17 do
                        send_script_event("Kick "..tostring(x), pid, {pid, generic_player_global(pid)})
                    end
                end
            end
        end
    end
)





_U_killing_eye_noice_time=0



-------------------Laser eye Done--------------------
_U_killing_eye_v1=menu.add_feature(
    "Laser eye V1",
    "toggle",
    main_self.id,
    function(a)
        if _U_killing_eye_noice_time<10 then
            menu.notify("Press X to use","Universe",5,6)
            _U_killing_eye_noice_time=_U_killing_eye_noice_time+1
        end
        local me=player.player_id()
        local my_ped=player.get_player_ped(me)
        while a.on do
            system.yield(0)
            local me=player.player_id()
            weapon.give_weapon_component_to_ped(my_ped,177293209,0x89EBDAA7)
            local my_ped=player.get_player_ped(me)
            if controls.get_control_normal(0,252)==0.0 then
                state=nil
            else
                state=1
            end
            while state do
                local success, v3_start = ped.get_ped_bone_coords(my_ped, 0x67f2, v3())
                while not success do
                    success, v3_start = ped.get_ped_bone_coords(my_ped, 0x67f2, v3())
                    system.wait(0)
                end
                local dir = cam.get_gameplay_cam_rot()
                dir:transformRotToDir()
                dir = dir * 1.5
                v3_start = v3_start + dir + v3(0,0,1)
                dir = nil
                local v3_end = player.get_player_coords(me)
                dir = cam.get_gameplay_cam_rot()
                dir:transformRotToDir()
                dir = dir * 1500
                v3_end = v3_end + dir
                gameplay.shoot_single_bullet_between_coords(v3_start, v3_end, 0, 3056410471, my_ped, true, false, 1000)
                gameplay.shoot_single_bullet_between_coords(v3_start, v3_end, 1, 177293209, my_ped, true, false, 1000)
                system.yield(0)
                ui.show_hud_component_this_frame(14)
                return HANDLER_CONTINUE
            end
            ui.show_hud_component_this_frame(14)
        end
    end

)

_U_killing_eye_v2=menu.add_feature(
    "Laser eye V2",
    "toggle",
    main_self.id,
    function(a)
        if _U_killing_eye_noice_time<10 then
            menu.notify("Press X to use","Universe",5,6)
            _U_killing_eye_noice_time=_U_killing_eye_noice_time+1
        end
        local me=player.player_id()
        local my_ped=player.get_player_ped(me)
        while a.on do
            system.yield(0)
            local me=player.player_id()
            weapon.give_weapon_component_to_ped(my_ped,1432025498,0x3BE4465D)
            local my_ped=player.get_player_ped(me)
            if controls.get_control_normal(0,252)==0.0 then
                state=nil
            else
                state=1
            end
            while state do
                local success, v3_start = ped.get_ped_bone_coords(my_ped, 0x67f2, v3())
                while not success do
                    success, v3_start = ped.get_ped_bone_coords(my_ped, 0x67f2, v3())
                    system.wait(0)
                end
                local dir = cam.get_gameplay_cam_rot()
                dir:transformRotToDir()
                dir = dir * 1.5
                v3_start = v3_start + dir + v3(0,0,1)
                dir = nil
                local v3_end = player.get_player_coords(me)
                dir = cam.get_gameplay_cam_rot()
                dir:transformRotToDir()
                dir = dir * 1500
                v3_end = v3_end + dir
                gameplay.shoot_single_bullet_between_coords(v3_start, v3_end, 0, 3056410471, my_ped, true, false, 1000)
                gameplay.shoot_single_bullet_between_coords(v3_start, v3_end, 1, 1432025498, my_ped, true, false, 1000)
                system.yield(0)
                ui.show_hud_component_this_frame(14)
                return HANDLER_CONTINUE
            end
            ui.show_hud_component_this_frame(14)
        end
    end

)

_U_killing_eye_v3=menu.add_feature(
    "Laser eye V3",
    "toggle",
    main_self.id,
    function(a)
        if _U_killing_eye_noice_time<10 then
            menu.notify("Press X to use","Universe",5,6)
            _U_killing_eye_noice_time=_U_killing_eye_noice_time+1
        end
        while a.on do
            system.yield(0)
            local me=player.player_id()
            local my_ped=player.get_player_ped(me)
            if controls.get_control_normal(0,252)==0.0 then
                state=nil
            else
                state=1
            end
            while state do
                local success, v3_start = ped.get_ped_bone_coords(my_ped, 0x67f2, v3())
                while not success do
                    success, v3_start = ped.get_ped_bone_coords(my_ped, 0x67f2, v3())
                    system.wait(0)
                end
                local dir = cam.get_gameplay_cam_rot()
                dir:transformRotToDir()
                dir = dir * 1.5
                v3_start = v3_start + dir + v3(0,0,1)
                dir = nil
                local v3_end = player.get_player_coords(me)
                dir = cam.get_gameplay_cam_rot()
                dir:transformRotToDir()
                dir = dir * 1500
                v3_end = v3_end + dir
                gameplay.shoot_single_bullet_between_coords(v3_start, v3_end, 0, 3056410471, my_ped, true, false, 1000)
                gameplay.shoot_single_bullet_between_coords(v3_start, v3_end, 1, 1834241177, my_ped, true, false, 1000)
                system.yield(0)
                ui.show_hud_component_this_frame(14)
                return HANDLER_CONTINUE
            end
            ui.show_hud_component_this_frame(14)
        end
    end

)


-------------------------Laser eye-------------------------------------
_U_protect_shield=menu.add_feature(
    "Glare Shield",
    "slider",
    main_self.id,
    function(a)
        while a.on do
            system.yield(0)
            local me=player.player_id()
            fire.add_explosion(player.get_player_coords(me)+v3(0,0,a.value),70,false,false,0,player.get_player_ped(me))
        end
    end
)
_U_protect_shield.max,_U_protect_shield.min,_U_protect_shield.mod=5,0,0.1


_U_invis_shield=menu.add_feature(
    "Aluminous Shield (anonymously planted)",
    "toggle",
    main_self.id,
    function(a)
        ui.notify_above_map("Please make sure that invincibility is turned on\nPlease make sure there are other non-friend players in the game","",0)
        while a.on do
            system.yield(0)
            local me=player.player_id()
            local pid=math.random(0,31)
            local my_ped=player.get_player_ped(me)
            ped.set_ped_health(my_ped,3280)
            if pid~=me and player.is_player_valid(pid) and not player.is_player_friend(pid) then
                fire.add_explosion(player.get_player_coords(me),29,false,true,0,player.get_player_ped(pid))
            end
            system.yield(0)
            ped.set_ped_health(my_ped,328)
        end
    end
)
_U_invis_shield_v2=menu.add_feature(
    "Aluminous Shield (Anonymous)",
    "toggle",
    main_self.id,
    function(a)
        ui.notify_above_map("Please make sure that invincibility is turned on","",0)
        while a.on do
            system.yield(0)
            local me=player.player_id()
            local my_ped=player.get_player_ped(me)
            ped.set_ped_health(my_ped,3280)
            fire.add_explosion(player.get_player_coords(me),29,false,true,0,me)
            system.yield(0)
            ped.set_ped_health(my_ped,328)
        end
    end
)
_U_invis_shield_v3=menu.add_feature(
    "Aluminous Shield",
    "toggle",
    main_self.id,
    function(a)
        ui.notify_above_map("Please make sure that invincibility is turned on","",0)
        while a.on do
            system.yield(0)
            local me=player.player_id()
            local my_ped=player.get_player_ped(me)
            ped.set_ped_health(my_ped,3280)
            fire.add_explosion(player.get_player_coords(me),29,false,true,0,player.get_player_ped(me))
            system.yield(0)
            ped.set_ped_health(my_ped,328)
        end
    end
)

function pass()
    return nil
end





local function is_pz(hash)
    if hash==487013001 or hash==1432025498 or hash==2017895192 or hash==2640438543 or hash==3800352039 or hash==2828843422 or hash==984333226 or hash==4019527611 or hash==317205821 or hash==94989220 then
        return 177293209
    else
        return hash
    end
end

_U_spin_16=menu.add_feature(     --翻译是这个-> _U_spin
    "spin1.6",
    "value_str",
    main_self.id,
    function(a)
        while a.on do
            system.yield(0)
            local me=player.player_id()
            local my_ped=player.get_player_ped(me)
            local rot=entity.get_entity_rotation(my_ped)
            if controls.get_control_normal(0,32)==1.0 or controls.get_control_normal(0,34)==1.0 or controls.get_control_normal(0,33)==1.0 or controls.get_control_normal(0,35)==1.0 or controls.get_control_normal(0,21)==1.0 or controls.get_control_normal(0,142)==1.0 or controls.get_control_normal(0,143)==1.0 then
                pass()
            else
                entity.set_entity_rotation(my_ped,rot + v3(math.random(0,1000),math.random(0,1000),math.random(0,1000)))
            end
            if a.value==0 then
                local all_peds=ped.get_all_peds()
                for i=1,#all_peds do
                    if not ped.is_ped_a_player(all_peds[i]) and entity.is_entity_a_ped(all_peds[i]) and not entity.is_entity_dead(all_peds[i]) then
                        local hash_weapon = is_pz(ped.get_current_ped_weapon(my_ped))
                        gameplay.shoot_single_bullet_between_coords(entity.get_entity_coords(all_peds[i])+v3(0,0,0.5), entity.get_entity_coords(all_peds[i])-v3(0,0,0.5), 1, hash_weapon, my_ped, true, false, 1000)
                    end
                end
            elseif a.value==1 then
                for i=1,31 do
                    if player.is_player_valid(i) and i~=player.player_id() then
                        if not entity.is_entity_dead(player.get_player_ped(i)) then
                            local hash_weapon = is_pz(ped.get_current_ped_weapon(my_ped))
                            gameplay.shoot_single_bullet_between_coords(player.get_player_coords(i)+v3(0,0,0.5), player.get_player_coords(i)-v3(0,0,0.5), 1, hash_weapon, my_ped, true, false, 1000)
                            return HANDLER_CONTINUE
                        end
                    end
                end
            elseif a.value==2 then
                local all_peds=ped.get_all_peds()
                for i=1,#all_peds do
                    if entity.is_entity_a_ped(all_peds[i]) and all_peds[i]~=my_ped and not entity.is_entity_dead(all_peds[i]) then
                        local hash_weapon = is_pz(ped.get_current_ped_weapon(my_ped))
                        gameplay.shoot_single_bullet_between_coords(entity.get_entity_coords(all_peds[i])+v3(0,0,0.5), entity.get_entity_coords(all_peds[i])-v3(0,0,0.5), 1, hash_weapon, my_ped, true, false, 1000)
                    end
                end
            end
        end
    end
)

_U_spin=menu.add_feature( --翻译是这个-> _U_spin
    "spin",
    "value_str",
    main_self.id,
    function(a)
        while a.on do
            system.yield(0)
            local me=player.player_id()
            local my_ped=player.get_player_ped(me)
            local rot=entity.get_entity_rotation(my_ped)
            if controls.get_control_normal(0,32)==1.0 or controls.get_control_normal(0,34)==1.0 or controls.get_control_normal(0,33)==1.0 or controls.get_control_normal(0,35)==1.0 or controls.get_control_normal(0,21)==1.0 or controls.get_control_normal(0,143)==1.0 then
                pass()
            else
                entity.set_entity_rotation(my_ped,v3(0,0,math.random(0,1000)))
            end
            if a.value==0 then
                local all_peds=ped.get_all_peds()
                for i=1,#all_peds do
                    if not ped.is_ped_a_player(all_peds[i]) and entity.is_entity_a_ped(all_peds[i]) and not entity.is_entity_dead(all_peds[i]) then
                        local hash_weapon = is_pz(ped.get_current_ped_weapon(my_ped))
                        gameplay.shoot_single_bullet_between_coords(entity.get_entity_coords(all_peds[i])+v3(0,0,0.5), entity.get_entity_coords(all_peds[i]), 1, hash_weapon, my_ped, true, false, 1000)
                    end
                end
            elseif a.value==1 then
                for i=1,31 do
                    if player.is_player_valid(i) and i~=player.player_id() then
                        if not entity.is_entity_dead(player.get_player_ped(i)) then
                            local hash_weapon = is_pz(ped.get_current_ped_weapon(my_ped))
                            gameplay.shoot_single_bullet_between_coords(player.get_player_coords(i)+v3(0,0,0.5), player.get_player_coords(i), 1, hash_weapon, my_ped, true, false, 1000)
                        end
                    end
                end
            elseif a.value==2 then
                local all_peds=ped.get_all_peds()
                for i=1,#all_peds do
                    if entity.is_entity_a_ped(all_peds[i]) and all_peds[i]~=my_ped and not entity.is_entity_dead(all_peds[i]) then
                        local hash_weapon = is_pz(ped.get_current_ped_weapon(my_ped))
                        gameplay.shoot_single_bullet_between_coords(entity.get_entity_coords(all_peds[i])+v3(0,0,0.5), entity.get_entity_coords(all_peds[i]), 1, hash_weapon, my_ped, true, false, 1000)
                    end
                end
            end
        end
    end
)


local spin_little=menu.add_feature(
    "Rage bot",
    "value_str",
    main_self.id,
    function(a)
        while a.on do
            system.yield(0)
            _U_spin.on=false
            local me=player.player_id()
            local my_ped=player.get_player_ped(me)
            local rot=entity.get_entity_rotation(my_ped)
            if controls.get_control_normal(0,32)==1.0 or controls.get_control_normal(0,34)==1.0 or controls.get_control_normal(0,33)==1.0 or controls.get_control_normal(0,35)==1.0 or controls.get_control_normal(0,21)==1.0 or controls.get_control_normal(0,143)==1.0 then
                pass()
                local z=cam.get_gameplay_cam_rot().z
                if controls.get_control_normal(0,32)==1.0 and controls.get_control_normal(0,34)==1.0 and controls.get_control_normal(0,33)==1.0 and controls.get_control_normal(0,35)==1.0 or controls.get_control_normal(0,34)==1.0 and controls.get_control_normal(0,35)==1.0 or controls.get_control_normal(0,32)==1.0 and controls.get_control_normal(0,33)==1.0 then
                    entity.set_entity_rotation(player.get_player_ped(player.player_id()),v3(0,0,z-180))--wasd
                elseif controls.get_control_normal(0,32)==1.0 and controls.get_control_normal(0,34)==1.0 and controls.get_control_normal(0,33)==1.0 then
                    entity.set_entity_rotation(player.get_player_ped(player.player_id()),v3(0,0,z+90))--wad
                elseif controls.get_control_normal(0,32)==1.0 and controls.get_control_normal(0,34)==1.0 then
                    entity.set_entity_rotation(player.get_player_ped(player.player_id()),v3(0,0,z+45))--wa
                elseif controls.get_control_normal(0,32)==1.0 and controls.get_control_normal(0,35)==1.0 then   
                    entity.set_entity_rotation(player.get_player_ped(player.player_id()),v3(0,0,z-45))--wd
                elseif controls.get_control_normal(0,33)==1.0 and controls.get_control_normal(0,35)==1.0 then
                    entity.set_entity_rotation(player.get_player_ped(player.player_id()),v3(0,0,z-135))--sd
                elseif controls.get_control_normal(0,33)==1.0 and controls.get_control_normal(0,34)==1.0 then
                    entity.set_entity_rotation(player.get_player_ped(player.player_id()),v3(0,0,z+135))--sa
                elseif controls.get_control_normal(0,33)==1.0 then
                    entity.set_entity_rotation(player.get_player_ped(player.player_id()),v3(0,0,z-180))--s
                elseif controls.get_control_normal(0,34)==1.0 then
                    entity.set_entity_rotation(player.get_player_ped(player.player_id()),v3(0,0,z+90))--a
                elseif controls.get_control_normal(0,35)==1.0 then
                    entity.set_entity_rotation(player.get_player_ped(player.player_id()),v3(0,0,z-90))--d
                else
                    entity.set_entity_rotation(player.get_player_ped(player.player_id()),v3(0,0,z))
                end
                system.yield(50)
                entity.set_entity_rotation(player.get_player_ped(player.player_id()),v3(0,0,z-180))
                is_running=true
            else
                local z=cam.get_gameplay_cam_rot().z
                entity.set_entity_rotation(player.get_player_ped(player.player_id()),v3(0,0,z-180))
                is_running=false
            end
            if a.value==0 then
                local all_peds=ped.get_all_peds()
                for i=1,#all_peds do
                    if not ped.is_ped_a_player(all_peds[i]) and entity.is_entity_a_ped(all_peds[i]) and not entity.is_entity_dead(all_peds[i]) then
                        local hash_weapon = is_pz(ped.get_current_ped_weapon(my_ped))
                        local npc_pos=entity.get_entity_rotation(all_peds[i])
                        if not is_running then
                            entity.set_entity_rotation(player.get_player_ped(player.player_id()),v3(0,0,npc_pos.z-180))
                            system.yield(0)
                            entity.set_entity_rotation(player.get_player_ped(player.player_id()),v3(0,0,cam.get_gameplay_cam_rot().z-180))
                        end
                        gameplay.shoot_single_bullet_between_coords(entity.get_entity_coords(all_peds[i]), entity.get_entity_coords(all_peds[i])+v3(0,0,0.5), 1, hash_weapon, my_ped, true, false, 1000)
                    end
                end
            elseif a.value==1 then
                for i=1,31 do
                    if player.is_player_valid(i) and i~=player.player_id() then
                        if not entity.is_entity_dead(player.get_player_ped(i)) then
                            local hash_weapon = is_pz(ped.get_current_ped_weapon(my_ped))
                            local npc_pos=player.get_player_coords(i)
                            if not is_running then
                                entity.set_entity_rotation(player.get_player_ped(player.player_id()),v3(0,0,npc_pos.z-180))
                                system.yield(0)
                                entity.set_entity_rotation(player.get_player_ped(player.player_id()),v3(0,0,cam.get_gameplay_cam_rot().z-180))
                            end
                            gameplay.shoot_single_bullet_between_coords(player.get_player_coords(i), player.get_player_coords(i)+v3(0,0,0.5), 1, hash_weapon, my_ped, true, false, 1000)
                        end
                    end
                end
            elseif a.value==2 then
                local all_peds=ped.get_all_peds()
                for i=1,#all_peds do
                    if all_peds[i]~=my_ped and not entity.is_entity_dead(all_peds[i]) then
                        local hash_weapon = is_pz(ped.get_current_ped_weapon(my_ped))
                        local npc_pos=entity.get_entity_rotation(all_peds[i])
                        if not is_running then
                            entity.set_entity_rotation(player.get_player_ped(player.player_id()),v3(0,0,npc_pos.z-180))
                            system.yield(0)
                            entity.set_entity_rotation(player.get_player_ped(player.player_id()),v3(0,0,cam.get_gameplay_cam_rot().z-180))
                        end
                        gameplay.shoot_single_bullet_between_coords(entity.get_entity_coords(all_peds[i]), entity.get_entity_coords(all_peds[i])+v3(0,0,0.5), 1, hash_weapon, my_ped, true, false, 1000)
                    end
                end
            end
        end
    end
)
_U_spin_16.threaded=true
_U_spin.threaded=true
spin_little.threaded=true
_U_spin_16:set_str_data({
    "spin NPC",
    "spin player",
    "spin NPC&player",
    "fake boby"
})

_U_spin:set_str_data({
    "spin NPC",
    "spin player",
    "spin NPC&player",
    "fake boby"
})
spin_little:set_str_data({
    "spin NPC",
    "spin player",
    "spin NPC&player",
    "fake boby"
})










_U_fast_respawn=menu.add_feature(
    "Return at the resurrection",
    "toggle",
    main_self.id,
    function(a)
        while a.on do
            system.yield(0)
            local me=player.player_id()
            local my_ped=player.get_player_ped(me)
            if ped.get_ped_health(my_ped)==0 then
                local lastpos=player.get_player_coords(me)
                c=0
                while true do
                    system.yield(0)
                    entity.set_entity_coords_no_offset(my_ped,lastpos)
                    if controls.is_control_pressed(0,32) or controls.is_control_pressed(0,34) or controls.is_control_pressed(0,33) or controls.is_control_pressed(0,35) or controls.is_control_pressed(0,21) or controls.is_control_pressed(0,114) or controls.is_control_pressed(0,142) or controls.is_control_pressed(0,143) then
                        break
                    end
                    
                end
            end
        end
    end
)



--------------Vehicle driving gun Done----------------------
local cross_hair = menu.add_feature(
    "AN_get_aim_function",
    "toggle",
    main_weapon.id,
    function(a)
        if a.on then
            ui.show_hud_component_this_frame(14)
            return HANDLER_CONTINUE
        end
        return HANDLER_POP
  end
)
cross_hair.hidden=true
function fuck_NPC_car(veh)
    entity.set_entity_coords_no_offset(veh,v3(0,0,0))
    ped.set_ped_health(veh,0)
    system.yield(0)
    local me=player.player_id()
    local my_ped=player.get_player_ped(me)
    cross_hair.on=true
    local veh=player.get_entity_player_is_aiming_at(me)
    local hash=entity.get_entity_model_hash(veh)
    if streaming.is_model_a_vehicle(hash) then
        ped.set_ped_into_vehicle(my_ped,veh,-1)
        cross_hair.on=false
    elseif streaming.is_model_a_ped(hash) then
        fuck_NPC_car(player.get_entity_player_is_aiming_at(me))
    end
end

function fuck_Player_car(veh)
    ped.clear_ped_tasks_immediately(veh)
    system.yield(0)
    local me=player.player_id()
    local my_ped=player.get_player_ped(me)
    cross_hair.on=true
    local veh=player.get_entity_player_is_aiming_at(me)
    local hash=entity.get_entity_model_hash(veh)
    if streaming.is_model_a_vehicle(hash) then
        cross_hair.on=false
        ped.set_ped_into_vehicle(my_ped,veh,-1)
    elseif ped.is_ped_a_player(veh) then
        fuck_Player_car(veh)
    else
        fuck_NPC_car(veh)
    end
end

_U_vehicle_driver_weapon=menu.add_feature(
    "Vehicle driving gun",
    "toggle",
    main_weapon.id,
    function(a)
        local hash=0
        while a.on do
            system.yield(0)
            local me=player.player_id()
            local my_ped=player.get_player_ped(me)
            local veh=player.get_entity_player_is_aiming_at(me)
            local hash=entity.get_entity_model_hash(veh)
            local pos=player.get_player_coords(me)
            if ped.is_ped_shooting(my_ped) then
                if streaming.is_model_a_vehicle(hash) then
                    ped.set_ped_into_vehicle(my_ped,veh,-1)
                elseif ped.is_ped_a_player(veh) then
                    fuck_Player_car(veh)
                elseif streaming.is_model_a_ped(hash) and ped.is_ped_in_any_vehicle(veh) then
                    fuck_NPC_car(veh)
                end
            end
        end
    end

)





-----------------Rope gun-----------------------------


local rope_resolve=menu.add_feature(
    "Rope analysis",
    "toggle",
    main_weapon.id,
    function(a)
        local me=player.player_id()
        local my_ped=player.get_player_ped(me)
        local rot = entity.get_entity_rotation(my_ped)
        while a.on do
            system.yield(0)
            --print(entity.has_entity_collided_with_anything(my_ped))
            if not entity.has_entity_collided_with_anything(my_ped) and _U_rope_weapon.on  then
                local pos=player.get_player_coords(me)
                local dir = cam.get_gameplay_cam_rot()
                entity.set_entity_collision(my_ped,true,true,true)
                dir:transformRotToDir()
                dir=v3(dir.x*1,dir.y*1,dir.z*1)
                pos=pos + dir
                entity.set_entity_coords_no_offset(my_ped,pos)
                entity.set_entity_rotation(my_ped,rot)
                system.yield(1)
            else
                rope_resolve.on=false
            end
        end
    end
)
rope_resolve.threaded=true



_U_rope_weapon=menu.add_feature(
    "Rope gun",
    "toggle",
    main_weapon.id,
    function(a)
        while a.on do
            system.yield(0)
            local me=player.player_id()
            local my_ped=player.get_player_ped(me)
            if ped.is_ped_shooting(my_ped) then
                rope_resolve.on=true
            end
            if entity.has_entity_collided_with_anything(my_ped) then
                rope_resolve.on=false
            end
        end
    end
)


_U_rope_weapon.hidden=true
rope_resolve.hidden=true



_U_phy_weapon=menu.add_feature(
    "Gravity gun (low version)",
    "toggle",
    main_weapon.id,
    function(a)
        while a.on do
            system.yield(0)
            local me=player.player_id()
            if player.get_entity_player_is_aiming_at(me) then
                local ent=player.get_entity_player_is_aiming_at(me)
                if ent~=0 then
                    local my_pos=player.get_player_coords(me)
                    local rot=cam.get_gameplay_cam_rot()
                    local dir=cam.get_gameplay_cam_rot()
                    dir:transformRotToDir()
                    dir=v3(dir.x*4,dir.y*4,dir.z*4)
                    if ped.is_ped_shooting(player.get_player_ped(me)) then
                        entity.set_entity_rotation(ent,rot)
                        if entity.is_entity_a_vehicle(ent) then
                            vehicle.set_vehicle_forward_speed(ent,100000)
                            system.yield(1000)
                            return HANDLER_CONTINUE
                        end
                    end
                    entity.set_entity_coords_no_offset(ent,my_pos+dir)
                    entity.set_entity_rotation(ent,entity.get_entity_rotation(ent))
                end
            end
        end
    end
)






------------------Fast shot Done---------------------------
---------------------The code here is based on revive---------------
_U_fast_shooter=menu.add_feature(
    "Fast shot",
    "toggle",
    main_weapon.id,
    function(a)
        while a.on do
            local me=player.player_id()
            local my_ped=player.get_player_ped(me)
            system.yield(0)
            if controls.get_control_normal(0,142)==0.0 then
                state=nil
            else
                state=1
            end
            while state do
                local success, v3_start = ped.get_ped_bone_coords(my_ped, 0x67f2, v3())
                while not success do
                    success, v3_start = ped.get_ped_bone_coords(my_ped, 0x67f2, v3())
                    system.wait(0)
                end
                local dir = cam.get_gameplay_cam_rot()
                dir:transformRotToDir()
                dir = dir * 1.5
                v3_start = v3_start + dir
                dir = nil
                local v3_end = player.get_player_coords(me)
                dir = cam.get_gameplay_cam_rot()
                dir:transformRotToDir()
                dir = dir * 1500
                v3_end = v3_end + dir
                local hash_weapon = ped.get_current_ped_weapon(my_ped)
                gameplay.shoot_single_bullet_between_coords(v3_start, v3_end, 1, hash_weapon, my_ped, true, false, 1000)
                system.yield(0)
                return HANDLER_CONTINUE
            end
        end
    end


)
-------------------------------------------------------

--_U_DT
_U_DT=menu.add_feature(     -- Double Tap <-翻译是这个
    "Double Tap",
    "toggle",
    main_weapon.id,
    function(a)
        while a.on do
            local me=player.player_id()
            local my_ped=player.get_player_ped(me)
            system.yield(0)
            while ped.is_ped_shooting(my_ped) do
                local success, v3_start = ped.get_ped_bone_coords(my_ped, 0x67f2, v3())
                while not success do
                    success, v3_start = ped.get_ped_bone_coords(my_ped, 0x67f2, v3())
                    system.wait(0)
                end
                local dir = cam.get_gameplay_cam_rot()
                dir:transformRotToDir()
                dir = dir * 1.5
                v3_start = v3_start + dir
                dir = nil
                local v3_end = player.get_player_coords(me)
                dir = cam.get_gameplay_cam_rot()
                dir:transformRotToDir()
                dir = dir * 1500
                v3_end = v3_end + dir
                local hash_weapon = ped.get_current_ped_weapon(my_ped)
                gameplay.shoot_single_bullet_between_coords(v3_start, v3_end, 1, hash_weapon, my_ped, true, false, 1000)
                system.yield(0)
                return HANDLER_CONTINUE
            end
        end
    end
)

---------------freeze session Done---------------------

_U_freeze_session=menu.add_feature(
    "freeze session",
    "toggle",
    main_net_all.id,
    function(a)
        while a.on do
            system.yield(0)
            for pid = 0, 31 do
				if player.is_player_valid(pid) 
				and player.player_id() ~= pid 
				and not player.is_player_friend(pid) 
				and not player.is_player_modder(pid, -1) 
				and not entity.is_entity_dead(player.get_player_ped(pid)) then
					ped.clear_ped_tasks_immediately(player.get_player_ped(pid))
				end
			end
        end
    end
)
------------------Chaotic session------------------------
function get_random_pid()
    local pid=math.random(0,31)
    if player.is_player_valid(pid) and not player.is_player_friend(pid) and player.player_id() ~= pid then
        return pid
    else
        return false
    end
end

_U_fuck_session=menu.add_feature(
    "Chaotic session",
    "toggle",
    main_net_all.id,
    function(a)
        while a.on do
            system.yield(0)
            for pid=0,31 do
                if player.is_player_valid(pid) and not player.is_player_friend(pid)  and player.player_id() ~= pid then
                    local killer=get_random_pid()
                    if killer then
                        fire.add_explosion(player.get_player_coords(pid),8,true,false,99999999,player.get_player_ped(killer))
                    end
                end
            end
        end
    end
)
-----------------Shake the game--------------------
_U_fuck_session2=menu.add_feature(
    "Shake the game",
    "toggle",
    main_net_all.id,
    function(a)
        while a.on do
            system.yield(0)
            for pid=0,31 do
                if player.is_player_valid(pid) and not player.is_player_friend(pid)  and player.player_id() ~= pid then
                    local killer=get_random_pid()
                    if killer then
                        fire.add_explosion(player.get_player_coords(pid)-v3(0,0,30),1,false,true,99999999,player.get_player_ped(killer))
                    end
                end
            end
        end
    end
)


local clip_board_chat_bot=menu.add_feature(
    "Send the contents of the clipboard to the public screen",
    "action",
    main_network.id,
    function(a)
        now_msg=''
        local msg=utils.from_clipboard()
        for i=1,#msg do
            now_msg=now_msg..string.char(string.byte(msg,i))
            --print(now_msg)
        end
        network.send_chat_message(tostring(now_msg),false)
    end
)
clip_board_chat_bot.hidden=true


---------------Swipe robot------------------

_U_ad_m=menu.add_feature(
    "Swipe robot",
    "toggle",
    main_network.id,
    function(a)
        local start_time=utils.time()
        while a.on do
            system.yield(0)
            network.send_chat_message("你\n妈\n死\n了\n你\n妈\n死\n了\n你\n妈\n死\n了\n你\n妈\n死\n了\n你\n妈\n死\n了\n你\n妈\n死\n了\n你\n妈\n死\n了\n你\n妈\n死\n了\n你\n妈\n死\n了\n你\n妈\n死\n了\n你\n妈\n死\n了\n你\n妈\n死\n了\n你\n妈\n死\n了\n你\n妈\n死\n了\n你\n妈\n死\n了\n你\n妈\n死\n了\n你\n妈\n死\n了\n你\n妈\n死\n了\n你\n妈\n死\n了",false)
            if utils.time()-start_time>=5 then
                cd_ad2.on=true
            end
        end
    end
)
cd_ad=menu.add_feature(
    "CD_Swipe robot",
    "toggle",
    main_network.id,
    function(a)
        menu.notify("Swipe robot Enter the CD period - 30s","Universe",2)
        system.yield(30000)
        cd_ad2.on=false
        menu.notify("Swipe robot Completed CD","Universe",2)
    end
)
cd_ad2=menu.add_feature(
    "CD_Swipe robot",
    "toggle",
    main_network.id,
    function(a)
        cd_ad.on=true
        while a.on do
            system.yield(0)
            _U_ad_m.on=false
        end
    end
)

cd_ad.hidden=true
cd_ad.threaded=true
cd_ad2.hidden=true
cd_ad2.threaded=true





























------------------------Menu Settings--------------------------

_U_ozark_titles={
    "Ozark's running scam？",
    "This is really a big joke, right?？",
    "Ozark the eternal god！！！",
    "What an obvious scam",
    "Ozark Update V38？",
    'Oh! We express our sincere apology',
    "It's like fine wine",
    "It looks so hot!!!! Well done",
    "Øzark",
    "Yes, we took your money and ran away！！",
    "We did not publish the source code, understand？",
    "Why are you still using Ozark？",
    "Why don't you buy a 2Take1? This sounds ridiculous, right？",
    "Remember to ask your friends and family to buy a Øzark, because it’s cool",
    "Øzark Beta",
    "Øzark Quit the scam？",
    "Oh! Do not! Why are you leaving~",
    "Yes, we received a fax from Take2 today",
    "Ask us to immediately shut down Øzark's server",
    "Don’t be sad, don’t be sad, because all dealers are losing money！",
    "Please don't embarrass them, they are all excellent people",
    "I don't know how to tell you this sad news",
    "Yes, as you can see, Lao Tzu is back！"
}



_U_ozark_title=menu.add_feature(
    "Øzark's header information",
    "toggle",
    main_options.id,
    function(a)
        local x=math.random(1,#_U_ozark_titles)
        local lenth=#_U_ozark_titles[x]*0.002+0.012
        while a.on do
            system.yield(0)
            ui.draw_rect(0.001, 0.999, 4.5, 0.085, 0, 0, 0, 0)
            ui.set_text_color(255, 255, 255, 125)				
            ui.set_text_scale(0.35)
            ui.set_text_font(0)
            ui.set_text_centre(true)
            ui.set_text_outline(true)
            ui.draw_text("F4",v2(0.5,0.16))
            ui.set_text_scale(0.4)
            ui.set_text_color(255, 100, 100, 225)
            ui.draw_text(_U_ozark_titles[x],v2(0.5-lenth,0.13))
        end
    end


)










_U_time_title=menu.add_feature(
    "Time information",
    "toggle",
    main_options.id,
    function(a)
        local r,g,b=math.random(0,255),math.random(0,255),math.random(0,255)
        while a.on do
            system.yield(0)
            local date=os.date("%H:%M:%S")
            ui.draw_rect(0.001, 0.999, 4.5, 0.085, 0, 0, 0, 0)
            ui.set_text_color(r,g,b, 255)				
            ui.set_text_scale(0.5)
            ui.set_text_font(1)
            ui.set_text_centre(true)
            ui.set_text_outline(true)
            ui.draw_text(date,v2(0.8,0.8))
        end
    end


)
_U_time_title.threaded=true
_U_time_title.hidden=false



--Host list

_U_host_info=menu.add_feature(
    "Host sequence",
    "toggle",
    main_options.id,
    function(a)
        local r,g,b=math.random(0,255),math.random(0,255),math.random(0,255)
        while a.on do
            local msg=''
            local msg2=''
            local msg3=''
            local msg4=''
            local msg5=''
            system.yield(0)
            for pid=0,31 do
                if player.is_player_valid(pid) then
                    player__U_host_info=player.get_player_host_priority(pid)
                    player_name=player.get_player_name(pid)
                    if player__U_host_info==1 then
                        msg='1. '..player_name
                    elseif player__U_host_info==2 then
                        msg2='\n2. '..player_name
                    elseif player__U_host_info==3 then
                        msg3='\n3. '..player_name
                    elseif player__U_host_info==4 then
                        msg4='\n4. '..player_name
                    elseif player__U_host_info==5 then
                        msg5='\n5. '..player_name
                    end
                end
            end
            ui.draw_rect(0.001, 0.999, 4.5, 0.085, 0, 0, 0, 0)
            ui.set_text_color(r,g,b, 255)				
            ui.set_text_scale(0.35)
            ui.set_text_font(1)
            ui.set_text_centre(false)
            ui.set_text_outline(true)
            ui.draw_text(msg..msg2..msg3..msg4..msg5..'\nYour serial number: '..player.get_player_host_priority(player.player_id()),v2(0.8,0.3),9999)
        end
    end
)























--------------------Protection options-------------------
----------------Mark all players Done------------------
_U_fuck_them=menu.add_feature(
    "Block sync--Mark all players",
    "toggle",
    main_protect.id,
    function(a)
        while a.on do
            system.yield(0)
            if a.on then
                for pid=0,31 do
                    if pid~=me and player.is_player_valid(pid) then
                        player.set_player_as_modder(pid,anti_sync)
                    end
                end
            else
                for pid=0,31 do
                    if pid~=me and player.is_player_valid(pid) then
                        player.unset_player_as_modder(pid,anti_sync)
                    end
                end
            end
        end
    end
                



)

local key_words={
    "QQ",
    "VX",
    "V.X",
    "Q.Q",
    "vx",
    "qq",
    "q.q",
    "v.x",
    "shua",
    "Shua",
    "SHUA",
    "SHUa",
    "sHUA",
    "微信",
    "威信",
    "萌新一起玩",
    "信用保障",
    "安全稳定",
    "解锁",
    "解所",
    "Q群",
    "q群",
    "全网最低",
    "全往最低",
    "店铺",
    "激情大片",
    "澳门赌场",
    "抠逼自慰",
    "加群",
    "刷钱",
    "淘宝",
    "十年店铺",
    "支持花呗",
    "地堡刷金",
    "有妹子",
    "扣群",
    "扣扣",
    "Î¢ÐÅ",
    "ÍþÐÅ",
    "ÃÈÐÂÒ»ÆðÍæ",
    "ÐÅÓÃ±£ÕÏ",
    "°²È«ÎÈ¶¨",
    "½âËø",
    "½âËù",
    "QÈº",
    "qÈº",
    "È«Íø×îµÍ",
    "È«Íù×îµÍ",
    "µêÆÌ",
    "¼¤Çé´óÆ¬",
    "°ÄÃÅ¶Ä³¡",
    "¿Ù±Æ×ÔÎ¿",
    "¼ÓÈº",
    "Ë¢Ç®",
    "ÌÔ±¦",
    "Ê®ÄêµêÆÌ",
    "Ö§³Ö»¨ßÂ",
    "µØ±¤Ë¢½ð",
    "ÓÐÃÃ×Ó",
    "¿ÛÈº",
    "¿Û¿Û",
    "Е�®Д©ӯ",
    "Е�ғД©ӯ",
    "ХҚҲФ–°Д�қХӢ·ГҶ�",
    "Д©ӯГ”�Д©�И��",
    "Е®‰Е…�Г�ЁЕ®�",
    "Х§ёИ”ғ",
    "Х§ёФ‰қ",
    "QГ�¤",
    "qГ�¤",
    "Е…�Г�‘Ф�қД�Ҷ",
    "Е…�Е�қФ�қД�Ҷ",
    "Е�—И“�",
    "Ф©қФҒ…Е¤§Г‰‡",
    "Ф�ЁИ—�ХӢҲЕ��",
    "Фҳ�Иқ�Х‡�Ф…°",
    "Еҳ�Г�¤",
    "Е�·И’±",
    "Ф·�Е®�",
    "ЕҷғЕ№�Е�—И“�",
    "Ф”�ФҲғХҳ±Е‘—",
    "Е�°Е�ӯЕ�·И‡‘",
    "Ф�‰Е¦№Е­Қ",
    "Ф‰ёГ�¤",
    "Ф‰ёФ‰ё",
    "寰�淇�",
    "濞佷俊",
    "钀屾柊涓€璧风帺",
    "淇＄敤淇濋殰",
    "瀹夊叏绋冲畾",
    "瑙ｉ攣",
    "瑙ｆ墍",
    "Q缇�",
    "q缇�",
    "鍏ㄧ綉鏈€浣�",
    "鍏ㄥ線鏈€浣�",
    "搴楅摵",
    "婵€鎯呭ぇ鐗�",
    "婢抽棬璧屽満",
    "鎶犻€艰嚜鎱�",
    "鍔犵兢",
    "鍒烽挶",
    "娣樺疂",
    "鍗佸勾搴楅摵",
    "鏀�鎸佽姳鍛�",
    "鍦板牎鍒烽噾",
    "鏈夊�瑰瓙",
    "鎵ｇ兢",
    "鎵ｆ墸",
    "ๅพฎไฟก",
    "ๅจ�ไฟก",
   "��ๆ–ฐไธ€่ตท็�ฉ",
   "ไฟก็”จไฟ�้��",
   "ๅฎ�ๅ…จ็จณๅฎ�",
   "งฃ้”�",
   "งฃๆ�€",
   "Q็พค",
   "q็พค",
    "ๅ…จ็ฝ‘ๆ�€ไฝ�",
    "ๅ…จๅพ€ๆ�€ไฝ�",
    "ๅบ—้“บ",
    "ๆฟ€ๆ�…ๅคง็��",
    "ๆพณ้—จ่ต�ๅ�บ",
    "ๆ� ้€ผ่�ชๆ…ฐ",
    "ๅ� ็พค",
    "ๅ�ท้’ฑ",
    "ๆท�ๅฎ�",
    "ๅ��ๅนดๅบ—้“บ",
    "ๆ”ฏๆ��่�ฑๅ‘—",
    "ๅ�ฐๅ กๅ�ท้�‘",
    "ๆ��ๅฆนๅญ�",
    "ๆ�ฃ็พค",
    "ๆ�ฃๆ�ฃ",
    ".com",
    ".cn",
    ".cc",
    ".xyz",
    ".top",
    ".us",
    ".ru",
    ".net",
    ".ad",
    ".ae",
    ".wang",
    ".pub",
    ".xin",
    ".cc",
    ".tv",
    ".uk",
    ".org",
    ".jp",
    ".edu",
    ".gov",
    ".mil",
    ".online",
    "ltd",
    ".shop",
    ".beer",
    ".art",
    ".luxe",
    ".co",
    ".vip",
    ".club",
    ".fun",
    ".tech",
    ".store",
    ".red",
    ".pro",
    ".kim",
    ".ink",
    ".group",
    ".work",
    ".ren",
    ".biz",
    ".mobi",
    ".site",
    ".asia",
    ".law",
    ".me",
    ".COM",
    ".CN",
    ".CC",
    ".XYZ",
    ".TOP",
    ".US",
    ".RU",
    ".NET",
    ".AD",
    ".AE",
    ".WANG",
    ".PUB",
    ".XIN",
    ".CC",
    ".TV",
    ".UK",
    ".ORG",
    ".JP",
    ".EDU",
    ".GOV",
    ".MIL",
    ".ONLINE",
    ".LTD",
    ".SHOP",
    ".BEER",
    ".ART",
    ".LUXE",
    ".CO",
    ".VIP",
    ".CLUB",
    ".FUN",
    ".TECH",
    ".STORE",
    ".RED",
    ".PRO",
    ".KIM",
    ".INK",
    ".GROUP",
    ".WORK",
    ".REN",
    ".BIZ",
    ".MOBI",
    ".SITE",
    ".ASIA",
    ".LAW",
    ".ME",
    ".cloud",
    ".love",
    ".press",
    ".space",
    ".video",
    ".fit",
    ".yoga",
    ".info",
    ".design",
    ".link",
    ".live",
    ".wiki",
    ".life",
    ".world",
    ".run",
    ".show",
    ".city",
    ".gold",
    ".today",
    ".plus",
    ".cool",
    ".icu",
    ".company",
    ".chat",
    ".zone",
    ".fans",
    ".host",
    ".center",
    ".email",
    ".fund",
    ".social",
    ".team",
    ".guru",
    ".CLOUD",
    ".LOVE",
    ".PRESS",
    ".SPACE",
    ".VIDEO",
    ".FIT",
    ".YOGA",
    ".INFO",
    ".DESIGN",
    ".LINK",
    ".LIVE",
    ".WIKI",
    ".LIFE",
    ".WORLD",
    ".RUN",
    ".SHOW",
    ".CITY",
    ".GOLD",
    ".TODAY",
    ".PLUS",
    ".COOL",
    ".ICU",
    ".COMPANY",
    ".CHAT",
    ".ZONE",
    ".FANS",
    ".HOST",
    ".CENTER",
    ".EMAIL",
    ".FUND",
    ".SOCIAL",
    ".TEAM",
    ".GURU"
}

local key_words_name={
    "shua",
    "Shua",
    "SHua",
    "SHUa",
    "SHUA",
    "sHua",
    "sHUa",
    "sHUA",
    "shUa",
    "ShUA",
    "shuA",
    "coin",
    "Coin",
    "COin",
    "COIn",
    "COIN",
    "cOin",
    "cOIn",
    "cOIN",
    "QQ",
    "Qq",
    "qQ",
    "qq",
    'VX',
    "vx",
    "Vx",
    "vX",
    "Qqun",
    "qQun",
    "q_qun",
    "q_Qun",
    "Q_Qun",
    "Q_QUN",
    "QUN_",
    "qun_",
    "Qun_"
}


-------------------Block advertising machine-----------------



local user_name_trial=menu.add_feature(
    "Detect player name",
    "toggle",
    main_protect.id,
    function(a)
        if a.on then
            user_name_trial_id=event.add_event_listener("player_join",function(b)
                local pid=b.player
                local player_name=player.get_player_name(pid)
                for i=1,#key_words_name do
                    if player_name:match("%"..key_words_name[i]) and player.is_player_friend(pid) and pid~=player.player_id() then
                        menu.notify("A similar advertising machine nickname detected\nMixed crash + kicked out player + mixed mission + apartment invitation + sent to the island + wrong player name：\n\n"..player.get_player_name(pid).."\nR*ID is\n"..player.get_player_scid(pid).."\nIP:"..intToIp(player.get_player_ip(pid)),"Universe",6,8)
                        if player.is_player_valid(pid) then
                            for x=0,4 do
                                send_script_event("Crash "..tostring(x), pid, {pid, generic_player_global(pid)})
                            end
                        end
                        if player.is_player_valid(pid) then
                            network.network_session_kick_player(pid)
                            send_script_event("Netbail kick", pid, {pid, generic_player_global(pid)})
                        end
                        if player.is_player_valid(pid) then
                            for x=0,17 do
                                send_script_event("Kick "..tostring(x), pid, {pid, generic_player_global(pid)})
                            end
                        end
                        if player.is_player_valid(pid) then
                            send_script_event("Transaction error", pid, {pid, generic_player_global(pid)})
                        end
                        if player.is_player_valid(pid) then
                            for x=1,3 do
                                send_script_event("Script host crash "..tostring(x), pid, {pid, generic_player_global(pid)})
                            end
                        end
                        if player.is_player_valid(pid) then
                            for x=1,300 do
                                send_script_event("Send to mission"..tostring(x), pid, {pid, generic_player_global(pid)})
                            end
                        end
                        if player.is_player_valid(pid) then
                            for x=1,300 do
                                send_script_event("Send to Perico island"..tostring(x), pid, {pid, generic_player_global(pid)})
                            end
                        end
                        if player.is_player_valid(pid) then
                            for x=1,300 do
                                send_script_event("Apartment invite"..tostring(x), pid, {pid, generic_player_global(pid)})
                            end
                        end
                        return HANDLER_CONTINUE
                    end
                end
            end)
        else
            event.remove_event_listener("player_join",user_name_trial_id)
        end
    end
)
user_name_trial.hidden=true
user_name_trial.threaded=true



_U_send_block_msg=menu.add_feature(
    "Send intercept information",
    "toggle",
    main_protect.id,
    function()
    end
)






_U_Chat_trial=menu.add_feature(
    "Block advertising machine",
    "toggle",
    main_protect.id,
    function(a)
        if a.on then
            _U_MSG1=''
            _U_MSG2=''
            _U_MSG3=''
            _U_MSG4=''
            _U_MSG5=''
            _U_now_chat_MSG=1
            user_name_trial.on=true
            _U_Chat_trial_id=event.add_event_listener("chat",function(b)
                local pid=b.player
                local msg=b.body
                if player.is_player_valid(pid) and not player.is_player_friend(pid) and pid~=player.player_id() then
                    for i=1,#key_words do
                        if msg:match("%"..key_words[i]) then
                            menu.notify("Advertising player detected\nMixed crash + kicked out player + mixed mission + apartment invitation + sent to the island + transaction error + blacklisted player name：\n\n"..player.get_player_name(pid).."\nR*ID is\n"..player.get_player_scid(pid).."\nIP:"..intToIp(player.get_player_ip(pid)),"Universe",6,8)
                            if _U_send_block_msg.on then
                                --local fasong_msg=string.format("U\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\nn\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\ni\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\nv\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\ne\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\nr\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\ns\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\ne\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\nUniverse1.6\n拦截广告机：%s",player.get_player_name(pid))
                                --local fasong_msg=fasong_msg.."\nIP:"..intToIp(player.get_player_ip(pid)).."\nR*ID:\n"..player.get_player_scid(pid).."\n欢迎加入2T交流群:872986398"
                                local fasong_msg='\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n'.._U_MSG1..'\n'.._U_MSG2..'\n'.._U_MSG3..'\n'.._U_MSG4..'\n'.._U_MSG5..'\n'..'Universe The ad player has been blocked for you:'..player.get_player_name(pid)
                                network.send_chat_message(fasong_msg,false)
                            end
                            local file=io.open(utils.get_appdata_path("PopstarDevs", "").."\\2Take1Menu\\cfg\\scid.cfg","a+")
                            local msg=file:read('*a')
                            if not string.find(msg,string.format("%x",player.get_player_scid(pid))) then
                                file:write("\nad_bot:"..string.format("%x",player.get_player_scid(pid))..":c")
                            end
                            io.close(file)
                            if player.is_player_valid(pid) then
                                for x=0,4 do
                                    send_script_event("Crash "..tostring(x), pid, {pid, generic_player_global(pid)})
                                end
                            end
                            if player.is_player_valid(pid) then
                                network.network_session_kick_player(pid)
                                send_script_event("Netbail kick", pid, {pid, generic_player_global(pid)})
                            end
                            if player.is_player_valid(pid) then
                                for x=0,17 do
                                    send_script_event("Kick "..tostring(x), pid, {pid, generic_player_global(pid)})
                                end
                            end
                            if player.is_player_valid(pid) then
                                send_script_event("Transaction error", pid, {pid, generic_player_global(pid)})
                            end
                            if player.is_player_valid(pid) then
                                for x=1,3 do
                                    send_script_event("Script host crash "..tostring(x), pid, {pid, generic_player_global(pid)})
                                end
                            end
                            if player.is_player_valid(pid) then
                                for x=1,300 do
                                    send_script_event("Send to mission", pid, {pid, generic_player_global(pid)})
                                end
                            end
                            if player.is_player_valid(pid) then
                                for x=1,300 do
                                    send_script_event("Send to Perico island", pid, {pid, generic_player_global(pid)})
                                end
                            end
                            if player.is_player_valid(pid) then
                                for x=1,300 do
                                    send_script_event("Apartment invite", pid, {pid, generic_player_global(pid)})
                                end
                            end
                            return HANDLER_CONTINUE
                        end
                    end
                    if _U_now_chat_MSG>=6 then
                        _U_MSG1=_U_MSG2
                        _U_MSG2=_U_MSG3
                        _U_MSG3=_U_MSG4
                        _U_MSG5=player.get_player_name(pid)..':'..msg
                    end
                    if _U_now_chat_MSG==1 then
                        _U_MSG1=player.get_player_name(pid)..':'..msg
                    elseif _U_now_chat_MSG==2 then
                        _U_MSG2=player.get_player_name(pid)..':'..msg
                    elseif _U_now_chat_MSG==3 then
                        _U_MSG3=player.get_player_name(pid)..':'..msg
                    elseif _U_now_chat_MSG==4 then
                        _U_MSG4=player.get_player_name(pid)..':'..msg
                    elseif _U_now_chat_MSG==5 then
                        _U_MSG5=player.get_player_name(pid)..':'..msg
                    end
                    _U_now_chat_MSG=_U_now_chat_MSG+1
                end
            end)
        else
            event.remove_event_listener("chat",_U_Chat_trial_id)
            user_name_trial.on=false
        end
    end
)


-----------------Bounce script--------------------
_U_anti_scrpit=menu.add_feature(
    "Bounce script event Beta",
    "toggle",
    main_protect.id,
    function(a)
        menu.notify("This feature is under test, and there may be unexpected bugs","Universe",5,6)
        if a.on then
            scrpit_hook_id=hook.register_script_event_hook(function(pid,me,script)
                --print(pid,me,scrpit)
                if pid~=me then
                    local script_id=script[1]
                    table.remove(script,1)
                    script.trigger_script_event(script_id,pid,script)
                    menu.notify("Received from"..player.get_player_name(pid).."Script event has bounced","Universe",5)
                end
            end)
        else
            hook.remove_script_event_hook(scrpit_hook_id)
        end
    end
)




------------------Ozark's protect Done------------------
_U_fuck_myself=menu.add_feature(
    "Øzark's emergency evacuation",
    "toggle",
    main_protect.id,
    function(a)
        while a.on do
            system.yield(0)
            local me=player.player_id()
            local pos=player.get_player_coords(me)
            if a.on then
                gameplay.clear_area_of_objects(pos,1000,0)
                gameplay.clear_area_of_vehicles(pos,100,false,false,false,false,false)
                gameplay.clear_area_of_peds(pos,1000,false)
                gameplay.clear_area_of_cops(pos,1000,false)
                local all_objs=object.get_all_objects()
                local all_peds=ped.get_all_peds()
                local all_vehicles=vehicle.get_all_vehicles()
                for i=1,#all_objs do
                    if all_objs[i] then
                        entity.delete_entity(all_objs[i])
                    end
                end
                for i=1,#all_peds do
                    if all_peds[i] and not ped.is_ped_a_player(all_peds[i]) then
                        entity.delete_entity(all_peds[i])
                    end
                end
                for i=1,#all_vehs do
                    if all_vehs[i] and all_vehs[i]~=player.get_player_vehicle(player.player_id()) then
                        entity.delete_entity(all_vehs[i])
                    end
                end
                for pid=0,31 do
                    if pid~=me and player.is_player_valid(pid) and a.on then
                        player.set_player_as_modder(pid,anti_sync)
                        player.set_player_visible_locally(pid,false)
                    end
                end
            else
                for pid=0,31 do
                    if pid~=me and player.is_player_valid(pid) then
                        player.unset_player_as_modder(pid,anti_sync)
                        player.set_player_visible_locally(pid,true)
                    end
                end
            end
        end
    end
)



--------------------------functions of AA-----------------------------

local function AA_location(me)
    local my_ped=player.get_player_ped(me)
    local pos=player.get_player_coords(me)
    entity.set_entity_coords_no_offset(my_ped,pos + v3(math.random(0,3),math.random(0,3),0))
    system.yield(0)
    entity.set_entity_coords_no_offset(my_ped,pos - v3(math.random(1,3),math.random(1,3),0))

end


local function Back_kill(pid,my_ped,me)
    local pos=player.get_player_coords(pid)
    local my_pos=player.get_player_coords(me)
    if my_pos>pos then
        entity.set_entity_coords_no_offset(my_ped,pos - v3(math.random(0,3),math.random(0,3),0))
    else
        entity.set_entity_coords_no_offset(my_ped,pos + v3(math.random(0,3),math.random(0,3),0))
    end
end

local function remove_player_gun(pid)
    local enemy_ped=player.get_player_ped(pid)
    local current_weapon=ped.get_current_ped_weapon(enemy_ped)
    weapon.remove_weapon_from_ped(enemy_ped,current_weapon)
end

local function freeze_player(pid)
    local enemy_ped=player.get_player_ped(pid)
    ped.clear_ped_tasks_immediately(enemy_ped)
end

local function ghost_head(pid,me,my_ped)
    local enemy_ped=player.get_player_ped(pid)
    local z=cam.get_gameplay_cam_rot().z
    if ped.is_ped_shooting(enemy_ped) then
        entity.set_entity_rotation(player.get_player_ped(player.player_id()),v3(0,0,z+90))
    else
        entity.set_entity_rotation(player.get_player_ped(player.player_id()),v3(0,0,z-90))
    end
    
end



----------------Anti - Aim-----------------------------
_U_Anti_aim=menu.add_feature(
    "Anti-Aim",
    "value_str",
    main_protect.id,
    function(a)
        while a.on do
            system.yield(0)
            local me=player.player_id()
            local my_ped=player.get_player_ped(me)
            for pid=0,31 do
                if player.is_player_valid(pid) and pid~=me and player.get_entity_player_is_aiming_at(pid)==my_ped then
                    if a.value==0 then
                        AA_location(me)
                    elseif a.value==1 then
                        Back_kill(pid,my_ped,me)
                    elseif a.value==2 then
                        remove_player_gun(pid)
                    elseif a.value==3 then
                        freeze_player(pid)
                    elseif a.value==4 then
                        ghost_head(pid,me,my_ped)
                    end
                end
            end
        end
    end

)
_U_Anti_aim:set_str_data({
    "fake boby",
    "Backstab",
    "Close the gun",
    "freeze",
    "Ghost probe"
}

)


---------------------Observer detection Done---------------
_U_fuck_spectater=menu.add_feature(
    "Monitor observer",
    "toggle",
    main_protect.id,
    function(a)
        local me=player.player_id()
        while a.on do
            system.yield(0)
            for pid=0,31 do
                if player.is_player_spectating(player.get_player_ped(pid)) and player.is_player_valid(pid) and pid~=me then
                    who = player.get_player_name(network.get_player_player_is_spectating(player.get_player_ped(pid)))
                    who_spec=player.get_player_name(player.get_player_ped(pid))
                    ui.draw_rect(0.001, 0.999, 4.5, 0.085, 0, 0, 0, 0)
                            ui.set_text_color(255, 255, 0, 255)				
                                    ui.set_text_scale(0.5)
                                    ui.set_text_font(0)
                                    ui.set_text_centre(true)
                                    ui.set_text_outline(true)
                                    ui.draw_text(who_spec.." Under observation "..who,v2(0.5,0.96))
                end
            end
        end
    end

)



_U_Anti_spectater=menu.add_feature(
    "Counter-observation",
    "toggle",
    main_protect.id,
    function(a)
        local me=player.player_id()
        local last_pos=player.get_player_coords(me)
        while a.on do
            system.yield(0)
            local me=player.player_id()
            local my_ped=player.get_player_ped(me)
            local last_pos=player.get_player_coords(me)
            if a.on then
                for pid=0,31 do
                    if player.is_player_spectating(player.get_player_ped(pid)) and player.is_player_valid(pid) and pid~=me and network.get_player_player_is_spectating(player.get_player_ped(pid))==me then
                        local pos=player.get_player_coords(pid)
                        entity.set_entity_coords_no_offset(my_ped,pos)
                        local me=player.player_id()
                        local my_ped=player.get_player_ped(me)
                        entity.set_entity_coords_no_offset(my_ped,last_pos)
                    end
                end
            else
                local me=player.player_id()
                local my_ped=player.get_player_ped(me)
                entity.set_entity_coords_no_offset(my_ped,last_pos)
            end
        end
    end

)

--------------------weapon--------------------
-------------------Rainbow Gun Done-------------
_U_main_weapon_color=menu.add_feature(
    "Rainbow Gun",
    "toggle",
    main_weapon.id,
    function(a)
        while a.on do
            for i, weapon_hash in pairs(weapon.get_all_weapon_hashes()) do
                if weapon.has_ped_got_weapon(player.get_player_ped(player.player_id()), weapon_hash) then
                    local number_of_tints = weapon.get_weapon_tint_count(weapon_hash)
                    if weapon_hash and weapon_hash ~= 2725352035 and number_of_tints > 0 then
                        weapon.set_ped_weapon_tint_index(player.get_player_ped(player.player_id()), weapon_hash, math.random(1, number_of_tints))
                    end
                end
            end
            system.yield(50)
        end
    end



)

_U_firework_gun=menu.add_feature(
    "Firework gun",
    "toggle",
    main_weapon.id,
    function(a)
        while a.on do
            local me=player.player_id()
            local my_ped=player.get_player_ped(me)
            system.yield(0)
            while ped.is_ped_shooting(my_ped) do
                local pos1=player.get_player_coords(me)
                local pos2 = player.get_player_coords(me)
                dir = cam.get_gameplay_cam_rot()
                dir:transformRotToDir()
                dir = dir*v3(30,30,30)
                pos1 = pos1 + dir
                dir = dir*v3(60,60,60)
                pos2 = pos2 + dir
                gameplay.shoot_single_bullet_between_coords(pos1,pos2, 1, 2138347493, my_ped, false, false, 2000)
                system.yield(0)
                return HANDLER_CONTINUE
            end
        end
    end
)

-------------------Missile burst Done--------------

_U_speed_fire_veh=menu.add_feature(
    "Car weapons Fast shot",
    "toggle",
    main_vehicle_menu.id,
    function(a)
        if a.on then
            local myped = player.get_player_ped(player.player_id())
            if ped.is_ped_in_any_vehicle(myped) == true then
              local Curveh = ped.get_vehicle_ped_is_using(myped)
              vehicle.set_vehicle_fixed(Curveh)
              vehicle.set_vehicle_deformation_fixed(Curveh)
            end
            return HANDLER_CONTINUE
        end
        return HANDLER_POP
    end
)
_U_unlock_max_speed=menu.add_feature(
    "Unlock vehicle speed limit",
    "toggle",
    main_vehicle_menu.id,
    function(a)
        if a.on then
            local my_veh=player.get_player_vehicle(player.player_id())
            entity.set_entity_max_speed(my_veh,999999999999999999)
        end

    end
)
_U_vehicle_flier=menu.add_feature(
    "Vehicle flight",
    "slider",
    main_vehicle_menu.id,
    function(a)
        while a.on do
            system.yield(0)
            local me=player.player_id()
            local my_ped=player.get_player_ped(me)
            if player.is_player_in_any_vehicle(me) then
                local my_veh=player.get_player_vehicle(me)
                --network.request_control_of_entity(my_veh)
                entity.set_entity_max_speed(my_veh,a.value)
                if controls.get_control_normal(0,32)==1.0 and controls.get_control_normal(0,34)==1.0 and controls.get_control_normal(0,33)==1.0 and controls.get_control_normal(0,35)==1.0 or controls.get_control_normal(0,34)==1.0 and controls.get_control_normal(0,35)==1.0 or controls.get_control_normal(0,32)==1.0 and controls.get_control_normal(0,33)==1.0 then
                    entity.set_entity_rotation(my_veh,cam.get_gameplay_cam_rot())
                    vehicle.set_vehicle_forward_speed(my_veh,0)
                elseif controls.get_control_normal(0,32)==1.0 and controls.get_control_normal(0,34)==1.0 and controls.get_control_normal(0,33)==1.0 then
                    entity.set_entity_rotation(my_veh,cam.get_gameplay_cam_rot())
                    vehicle.set_vehicle_forward_speed(my_veh,a.value)
                elseif  controls.get_control_normal(0,32)==1.0 and controls.get_control_normal(0,34)==1.0 then
                    entity.set_entity_rotation(my_veh,cam.get_gameplay_cam_rot()+v3(0,0,45))
                    vehicle.set_vehicle_forward_speed(my_veh,a.value)
                elseif controls.get_control_normal(0,32)==1.0 and controls.get_control_normal(0,35)==1.0 then 
                    entity.set_entity_rotation(my_veh,cam.get_gameplay_cam_rot()-v3(0,0,45))
                    vehicle.set_vehicle_forward_speed(my_veh,a.value)
                elseif controls.get_control_normal(0,33)==1.0 and controls.get_control_normal(0,35)==1.0 then
                    entity.set_entity_rotation(my_veh,cam.get_gameplay_cam_rot()-v3(0,0,135))
                    vehicle.set_vehicle_forward_speed(my_veh,a.value)
                elseif controls.get_control_normal(0,33)==1.0 and controls.get_control_normal(0,34)==1.0 then
                    entity.set_entity_rotation(my_veh,cam.get_gameplay_cam_rot()+v3(0,0,135))
                    vehicle.set_vehicle_forward_speed(my_veh,a.value)
                elseif controls.get_control_normal(0,33)==1.0 then
                    entity.set_entity_rotation(my_veh,cam.get_gameplay_cam_rot()-v3(0,0,180))
                    vehicle.set_vehicle_forward_speed(my_veh,a.value)
                elseif controls.get_control_normal(0,34)==1.0 then
                    entity.set_entity_rotation(my_veh,cam.get_gameplay_cam_rot()+v3(0,0,90))
                    vehicle.set_vehicle_forward_speed(my_veh,a.value)
                elseif controls.get_control_normal(0,35)==1.0 then
                    entity.set_entity_rotation(my_veh,cam.get_gameplay_cam_rot()-v3(0,0,90))
                    vehicle.set_vehicle_forward_speed(my_veh,a.value)
                elseif controls.get_control_normal(0,32)==1.0 then
                    vehicle.set_vehicle_forward_speed(my_veh,a.value)
                    entity.set_entity_rotation(my_veh,cam.get_gameplay_cam_rot())
                else
                    vehicle.set_vehicle_forward_speed(my_veh,0)
                    entity.set_entity_rotation(my_veh,cam.get_gameplay_cam_rot())

                end
                if controls.get_control_normal(0,21)==1.0 or controls.get_control_normal(0,143)==1.0 then
                    entity.set_entity_velocity(my_veh,v3(0,0,a.value))
                elseif controls.get_control_normal(0,132)==1.0 then
                    entity.set_entity_velocity(my_veh,v3(0,0,a.value*-1))
                end

            else
                set_vehicle_fixed(player.get_player_ped(player.player_id()))
            end
        end
    end
)
--_U_vehicle_flier.hidden=true

_U_vehicle_flier.max,_U_vehicle_flier.min,_U_vehicle_flier.mod=1500,50,50
-------------------Car parachute-----------------------
--------------------------------------------------

_U_veh_boost=menu.add_feature(
    "Quick recharge of vehicles",
    "toggle",
    main_vehicle_menu.id,
    function(a)
        local state=0
        while a.on do
            system.yield(0)
            local me=player.player_id()
            local my_ped=player.get_player_ped(me)
            if ped.is_ped_in_any_vehicle(my_ped) then
                local veh=ped.get_vehicle_ped_is_using(my_ped)
                vehicle.set_vehicle_rocket_boost_refill_time(veh,0)
            end
        end
    end
)

_U_veh_boost_infinity=menu.add_feature(
    "Vehicle unlimited charge accelerate",
    "toggle",
    main_vehicle_menu.id,
    function(a)
        local state=0
        while a.on do
            system.yield(0)
            local me=player.player_id()
            local my_ped=player.get_player_ped(me)
            if ped.is_ped_in_any_vehicle(my_ped) then
                local veh=ped.get_vehicle_ped_is_using(my_ped)
                vehicle.set_vehicle_rocket_boost_percentage(veh,999999.0)
            end
        end
    end
)


_U_veh_auto_boost=menu.add_feature(
    "Vehicle automatically accelerate",
    "toggle",
    main_vehicle_menu.id,
    function(a)
        local state=0
        while a.on do
            system.yield(0)
            local me=player.player_id()
            local my_ped=player.get_player_ped(me)
            if ped.is_ped_in_any_vehicle(my_ped) then
                local veh=ped.get_vehicle_ped_is_using(my_ped)
                vehicle.set_vehicle_rocket_boost_active(veh,true)
            end
        end
    end
)


_U_fix_drive_on_water=menu.add_feature(
    'Repair water driving',
    'toggle',
    main_vehicle_menu.id,
    function()
        menu.notify('Use it if water driving doesnt work','Universe',2,4)
    end
)

vobjs={}
_U_veh_on_water=menu.add_feature(
    "Vehicle water driving",
    "toggle",
    main_vehicle_menu.id,
    function(a)
        while a.on do
            system.yield(0)
            if player.is_player_in_any_vehicle(player.player_id()) and entity.is_entity_in_water(player.get_player_vehicle(player.player_id())) and is_player_move(player.get_player_coords(player.player_id())) and _U_fix_drive_on_water.on then
                local obj=object.create_world_object(110106994,player.get_player_coords(player.player_id())-v3(0,0,0.55),true,true)
                system.yield(0)
                entity.set_entity_visible(obj,false)
                vobjs[#vobjs+1]=obj
                if #vobjs>=30 then
                    for obj=1,#vobjs do
                        entity.delete_entity(vobjs[obj])
                    end
                    vobjs={}
                end
            elseif player.is_player_in_any_vehicle(player.player_id()) and entity.is_entity_in_water(player.get_player_vehicle(player.player_id())) and is_player_move(player.get_player_coords(player.player_id()))then
                local obj=object.create_world_object(110106994,player.get_player_coords(player.player_id())-v3(0,0,1.25),true,true)
                entity.set_entity_visible(obj,false)
                vobjs[#vobjs+1]=obj
                if #vobjs>=30 then
                    for obj=1,#objs do
                        entity.delete_entity(vobjs[obj])
                    end
                    vobjs={}
                end
            else
                if vobjs[2] then
                    for obj=1,#vobjs-1 do
                        entity.delete_entity(vobjs[obj])
                    end
                    vobjs={}
                end
            end
            if not a.on then
                if vobjs[1] then
                    for obj=1,#vobjs do
                        entity.delete_entity(vobjs[obj])
                    end
                    vobjs={}
                end
            end
        end
    end
)




--------------Automatic cutting gun Done----------------
_U_main_weapon_switch=menu.add_feature(
    "Automatic cutting gun",
    "toggle",
    main_weapon.id,
    function(a)
        if a.on then
            if Pedshoot() then
                if Pedweapon() == 0xA284510B then
                    weapon.remove_weapon_from_ped(Myped(), 0xA284510B)
                    weapon.give_delayed_weapon_to_ped(Myped(), 0xA284510B, 0, 1)
                    weapon.set_ped_ammo(Myped(), 0xA284510B, 2147483647)
                elseif Pedweapon() == 0xB1CA77B1 then
                    weapon.remove_weapon_from_ped(Myped(), 0xB1CA77B1)
                    weapon.give_delayed_weapon_to_ped(Myped(), 0xB1CA77B1, 0, 1)
                    weapon.set_ped_ammo(Myped(), 0xB1CA77B1, 2147483647)
                elseif Pedweapon() == 0x7F7497E5 then
                    weapon.remove_weapon_from_ped(Myped(), 0x7F7497E5)
                    weapon.give_delayed_weapon_to_ped(Myped(), 0x7F7497E5, 0, 1)
                    weapon.set_ped_ammo(Myped(), 0x7F7497E5, 2147483647)
                elseif Pedweapon() == 0x6D544C99 then
                    weapon.remove_weapon_from_ped(Myped(), 0x6D544C99)
                    weapon.give_delayed_weapon_to_ped(Myped(), 0x6D544C99, 0, 1)
                    weapon.set_ped_ammo(Myped(), 0x6D544C99, 2147483647)
                elseif Pedweapon() == 0x63AB0442 then
                    weapon.remove_weapon_from_ped(Myped(), 0x63AB0442)
                    weapon.give_delayed_weapon_to_ped(Myped(), 0x63AB0442, 0, 1)
                    weapon.set_ped_ammo(Myped(), 0x63AB0442, 2147483647)
                elseif Pedweapon() == 0x0781FE4A then
                    weapon.remove_weapon_from_ped(Myped(), 0x0781FE4A)
                    weapon.give_delayed_weapon_to_ped(Myped(), 0x0781FE4A, 0, 1)
                    weapon.set_ped_ammo(Myped(), 0x0781FE4A, 2147483647)
                elseif Pedweapon() == 0x05FC3C11 then
                    weapon.remove_weapon_from_ped(Myped(), 0x05FC3C11)
                    weapon.give_delayed_weapon_to_ped(Myped(), 0x05FC3C11, 0, 1)
                    weapon.set_ped_ammo(Myped(), 0x05FC3C11, 2147483647)
                elseif Pedweapon() == 0x0C472FE2 then
                    weapon.remove_weapon_from_ped(Myped(), 0x0C472FE2)
                    weapon.give_delayed_weapon_to_ped(Myped(), 0x0C472FE2, 0, 1)
                    weapon.set_ped_ammo(Myped(), 0x0C472FE2, 2147483647)
                elseif Pedweapon() == 0xA914799 then
                    weapon.remove_weapon_from_ped(Myped(), 0xA914799)
                    weapon.give_delayed_weapon_to_ped(Myped(), 0xA914799, 0, 1)
                    weapon.set_ped_ammo(Myped(), 0xA914799, 2147483647)
                elseif Pedweapon() == 0xC734385A then
                    weapon.remove_weapon_from_ped(Myped(), 0xC734385A)
                    weapon.give_delayed_weapon_to_ped(Myped(), 0xC734385A, 0, 1)
                    weapon.set_ped_ammo(Myped(), 0xC734385A, 2147483647)
                elseif Pedweapon() == 0x6A6C02E0 then
                    weapon.remove_weapon_from_ped(Myped(), 0x6A6C02E0)
                    weapon.give_delayed_weapon_to_ped(Myped(), 0x6A6C02E0, 0, 1)
                    weapon.set_ped_ammo(Myped(), 0x6A6C02E0, 2147483647)
                end
            end
            return HANDLER_CONTINUE
        end
        return HANDLER_POP
    end
)


_U_guide_missile=menu.add_feature(
    'Auto guide (range)',
    'value_i',
    main_weapon.id,
    function(a)
        while a.on do
            system.yield(0)
            if ped.is_ped_shooting(player.get_player_ped(player.player_id())) then
                for pid=0,31 do
                    if pid~=player.player_id() and not player.is_player_friend(pid) then
                        if distanceTo(pid)<a.value then
                            local hash_weapon = ped.get_current_ped_weapon(player.get_player_ped(player.player_id()))
                            gameplay.shoot_single_bullet_between_coords(player.get_player_coords(player.player_id()), player.get_player_coords(pid), 1, hash_weapon, player.get_player_ped(player.player_id()), true, false, 1000)
                        end
                    end
                end
            end
        end
    end
)
_U_guide_missile.min,_U_guide_missile.max,_U_guide_missile.mod=100,10000,25


-------------Automatically skip cutscenes Done--------------
_U_main_auto_skip=menu.add_feature(
    "Automatically skip cutscenes",
    "toggle",
    mission_cheat.id,
    function(a)
        while a.on do
            system.yield(0)
            if cutscene.is_cutscene_active() or cutscene.is_cutscene_playing() then
                cutscene.stop_cutscene_immediately()
                cutscene.remove_cutscene()
            else
                return HANDLER_CONTINUE
            end
        end
    end
)

local go_forward=menu.add_feature(
    'Go forward some distance',
    "action",
    mission_cheat.id,
    function()
        local me=player.player_id()
        local my_ped=player.get_player_ped(me)
        local pos=player.get_player_coords(me)
        local dir = cam.get_gameplay_cam_rot()
        dir:transformRotToDir()
        -- dir = dir +1.5
        -- dir=dit*2
        dir=v3(dir.x*3,dir.y*3,dir.z*3)
        pos=pos + dir
        entity.set_entity_coords_no_offset(my_ped,pos)
    end
)

_U_clear_notice=menu.add_feature("Cleanup notice", "toggle", mission_cheat.id, function(a)
    while a.on do
        ui.get_current_notification(ui.remove_notification(0))
    if not a.on then return end
    system.wait(1)
    end
    end)




----------------------Anti - NPC---------------------
_U_Anti_Npc=menu.add_feature(
    "KillNPC",
    "toggle",
    mission_cheat.id,
    function(a)
        while a.on do
            system.yield(0)
            all_peds=ped.get_all_peds()
            for i=1,#all_peds do
                if not ped.is_ped_a_player(all_peds[i]) then
                    ped.set_ped_health(all_peds[i],0)
                end
            end
        end
    end
)

-----------------Troll NPC?--------------------
_U_Anti_Npc_Aim_Shoot=menu.add_feature(
    "Troll NPC",
    "toggle",
    mission_cheat.id,
    function(a)
        local c={}
        while a.on do
            system.yield(0)
            all_peds=ped.get_all_peds()
            if all_peds then
                for i=1,#all_peds do
                    system.yield(0)
                    if not ped.is_ped_a_player(all_peds[i]) and entity.is_entity_a_ped(all_peds[i]) and not entity.is_entity_dead(all_peds[i]) then
                        ped.set_ped_can_switch_weapons(all_peds[i],false)
                        weapon.remove_all_ped_weapons(all_peds[i])
                        entity.freeze_entity(all_peds[i],true)
                    end
                end
            end
        end
    end
)

_U_Anti_Npc_Aim_Shoot.threaded=true

_U_make_NPC_Fire=menu.add_feature(
    "Ignite NPC",
    "toggle",
    mission_cheat.id,
    function(a)
        local c={}
        while a.on do
            system.yield(0)
            all_peds=ped.get_all_peds()
            if all_peds then
                for i=1,#all_peds do
                    if not ped.is_ped_a_player(all_peds[i]) and entity.is_entity_a_ped(all_peds[i]) and not entity.is_entity_dead(all_peds[i]) and a.on then
                        fire.start_entity_fire(all_peds[i])
                    end
                    system.yield(10)
                end
            end
        end
    end
)
_U_make_NPC_Fire.hidden=true
_U_make_NPC_Fire.threaded=true
_U_main_title.on=true


_U_cai_dan_alien=menu.add_feature("Alien Egg Shipping (Easter Eggs)", "toggle", mission_cheat.id, function(a)
    menu.notify("Go to the bunker to buy goods\nThanks to the group friends for the code and ideas", "Unlock master", 3, 0x6414F0FF)
    menu.notify("2T玩家交流群：872986398\n买科技加群775255063", "Unlock master", 3, 0x6414F0FF)
    while a.on do
        if a.on then
            system.yield(0)
            local ALN_EG_MS = {
                {"LFETIME_BIKER_BUY_COMPLET5", 600},
                {"LFETIME_BIKER_BUY_UNDERTA5", 600}
            }
            local hash0 = stats.stat_get_int(gameplay.get_hash_key("MP0_LFETIME_BIKER_BUY_COMPLET5"),0,true)
            local hash1 = stats.stat_get_int(gameplay.get_hash_key("MP1_LFETIME_BIKER_BUY_COMPLET5"),0,true)
            local hash2 = stats.stat_get_int(gameplay.get_hash_key("MP0_LFETIME_BIKER_BUY_UNDERTA5"),0,true)
            local hash3 = stats.stat_get_int(gameplay.get_hash_key("MP1_LFETIME_BIKER_BUY_UNDERTA5"),0,true)
            if hash0<600 or hash1<600 or hash2<600 or hash3<600 then
                for i = 1, #ALN_EG_MS do
                    stats.stat_set_int(ALN_EG_MS[i][1], true, ALN_EG_MS[i][2])
                end
            end
            ui.draw_rect(0.001, 0.999, 4.5, 0.085, 0, 0, 0, 0)
            ui.set_text_color(255, 0, 0, 255)				
            ui.set_text_scale(0.5)
            ui.set_text_font(0)
            ui.set_text_centre(true)
            ui.set_text_outline(true)
            ui.draw_text('You are in the easter egg delivery mode, doing tasks/Please turn off this function when selling goods\nOtherwise there will be fatal bugs',v2(0.5,0.85))
            script.set_global_i(2544210+5191+342,20)
        end
    end
end)

main____ylbs={}
ylbs___pids={}
_U_spawn_ylb=menu.add_feature(
    "Strong protection",
    'toggle',
    mission_cheat.id,
    function(a)
        while a.on do
            system.yield(0)
            for pid=0,31 do
                if player.is_player_vaild(pid) then-- and pid~=player.player_id()
                    if player.get_player_max_health(pid)>player.get_player_health(pid) then
                        for i=1,#ylbs___pids do
                            if pid==ylbs___pids[i] then
                                return HANDLER_CONTINUE
                            end
                        end
                        local obj=object.create_world_object(410882957,player.get_player_coords(pid),true,true)
                        entity.attach_entity_to_entity(obj,player.get_player_ped(pid),0,v3(0,0,0),v3(0,0,0),true,true,true,0,true)
                        main____ylbs[#main____ylbs+1]=obj
                        system.yield(1)
                        entity.set_entity_visible(obj,false)
                        local obj=object.create_world_object(410882957,player.get_player_coords(pid),true,true)
                        entity.attach_entity_to_entity(obj,player.get_player_ped(pid),0,v3(0,0,-0.5),v3(0,0,0),true,true,true,0,true)
                        main____ylbs[#main____ylbs+1]=obj
                        system.yield(1)
                        entity.set_entity_visible(obj,false)
                        local obj=object.create_world_object(410882957,player.get_player_coords(pid),true,true)
                        entity.attach_entity_to_entity(obj,player.get_player_ped(pid),0,v3(0,0,0.5),v3(0,0,0),true,true,true,0,true)
                        main____ylbs[#main____ylbs+1]=obj
                        system.yield(1)
                        entity.set_entity_visible(obj,false)
                        ylbs___pids[#ylbs___pids+1]=pid
                        if #main____ylbs>15 then
                            for i=1,#main____ylbs do
                                entity.delete_entity(main____ylbs[i])
                            end
                            main____ylbs={}
                        end
                        system.yield(100)
                    end
                end
            end
        end
    end
)
_U_spawn_ylb.threaded=true
_U_spawn_ylb.hidden=true


_U_invi_god_items={}
_U_invi_god=menu.add_feature(
    'Invisible to teammates',
    "toggle",
    mission_cheat.id,
    function(a)
        if a.on then
            _U_spawn_ylb.on=true
            for pid=0,31 do
                if player.is_player_vaild(pid) then-- and pid~=player.player_id()
                    local obj=object.create_object(1399999408,player.get_player_coords(player.player_id())+v3(0,0,5),true,true)
                    entity.attach_entity_to_entity(obj,player.get_player_ped(pid),0,v3(0,0,0),v3(0,0,0),true,false,true,0,true)
                    _U_invi_god_items[#_U_invi_god_items+1]=obj
                    system.yield(1)
                    entity.set_entity_visible(obj,false)
                end
            end
            
        else
            _U_spawn_ylb.on=false
            if _U_invi_god_items then
                for i=1,#_U_invi_god_items do
                    entity.delete_entity(_U_invi_god_items[i])
                end
                _U_invi_god_items={}
            end
            ylbs___pids={}
            if main____ylbs then
                for i=1,#main____ylbs do
                    entity.delete_entity(main____ylbs[i])
                end
                main____ylbs={}
            end
        end
    end
)


_U_Tp_all_to_me=menu.add_feature(
    'Send teammates to me',
    'action',
    mission_cheat.id,
    function(a)
        if a.on then
            system.yield(0)
            local main_pos=player.get_player_coords(player.player_id())
            for pid=0,31 do
                if player.is_player_vaild(pid) and pid~=player.player_id() then
                    if player.is_player_in_any_vehicle(pid) then
                        local dir = cam.get_gameplay_cam_rot()
                        dir:transformRotToDir()
                        dir=v3(dir.x*5,dir.y*5,dir.z*5)
                        local main_pos=player.get_player_coords(player.player_id())+dir
                        local veh=player.get_player_vehicle(pid)
                        entity.set_entity_coords_no_offset(player.get_player_ped(player.player_id()),player.get_player_coords(pid)+v3(0,0,10))
                        system.yield(5000)
                        entity.set_entity_coords_no_offset(veh,main_pos)
                        --system.yield(1000)
                        entity.set_entity_coords_no_offset(player.get_player_ped(player.player_id()),main_pos-dir)
                        system.yield(1000)
                    end
                end
            end
        end 
    end
)
_U_Tp_all_to_me.hidden=true
local clear_dead=menu.add_feature(
    "Clear the killed record[!]",
    "toggle",
    mission_cheat.id,
    function(a)
        while a.on do
            system.yield(0)
            stats.stat_set_int(gameplay.get_hash_key('MP0_ARCHENEMY_KILLS'),0,true)
            stats.stat_set_int(gameplay.get_hash_key('MP1_ARCHENEMY_KILLS'),0,true)
            stats.stat_set_int(gameplay.get_hash_key('MP0_DEATHS'),0,true)
            stats.stat_set_int(gameplay.get_hash_key('MP1_DEATHS'),0,true)
            stats.stat_set_int(gameplay.get_hash_key('MP0_DIED_IN_EXPLOSION'),0,true)
            stats.stat_set_int(gameplay.get_hash_key('MP1_DIED_IN_EXPLOSION'),0,true)
            stats.stat_set_int(gameplay.get_hash_key('MP0_DIED_IN_FALL'),0,true)
            stats.stat_set_int(gameplay.get_hash_key('MP1_DIED_IN_FALL'),0,true)
            stats.stat_set_int(gameplay.get_hash_key('MP0_DIED_IN_FIRE'),0,true)
            stats.stat_set_int(gameplay.get_hash_key('MP1_DIED_IN_FIRE'),0,true)
            stats.stat_set_int(gameplay.get_hash_key('MP0_DIED_IN_ROAD'),0,true)
            stats.stat_set_int(gameplay.get_hash_key('MP1_DIED_IN_ROAD'),0,true)
            stats.stat_set_int(gameplay.get_hash_key('MP0_DIED_IN_DROWNING'),0,true)
            stats.stat_set_int(gameplay.get_hash_key('MP1_DIED_IN_DROWNING'),0,true)
        end
    end
)
local cooldown_clear=menu.add_feature(
    "Remove casino chip cooldown[!]",
    "toggle",
    mission_cheat.id,
    function(a)
        while a.on do
            system.yield(0)
            if stats.stat_get_int(gameplay.get_hash_key('MPPLY_CASINO_CHIPS_PUR_GD'),0)~=0 then
                menu.notify('Purchase history reset','Universe',3,2)
                stats.stat_set_int(gameplay.get_hash_key('MPPLY_CASINO_CHIPS_PUR_GD'),0,true)
            end
        end
    end
)



local clear_cash=menu.add_feature(
    "Remove the balance of payments[!]",
    "action",
    mission_cheat.id,
    function()
        local a=stats.stat_get_int(gameplay.get_hash_key('MP0_MONEY_SPENT_WEAPON_ARMOR'),0)
        a=a+stats.stat_get_int(gameplay.get_hash_key('MP1_MONEY_SPENT_WEAPON_ARMOR'),0)
        a=a+stats.stat_get_int(gameplay.get_hash_key('MP0_MONEY_SPENT_VEH_MAINTENANCE'),0)
        a=a+stats.stat_get_int(gameplay.get_hash_key('MP1_MONEY_SPENT_VEH_MAINTENANCE'),0)
        a=a+stats.stat_get_int(gameplay.get_hash_key('MP0_MONEY_SPENT_STYLE_ENT'),0)
        a=a+stats.stat_get_int(gameplay.get_hash_key('MP1_MONEY_SPENT_STYLE_ENT'),0)
        a=a+stats.stat_get_int(gameplay.get_hash_key('MP0_MONEY_SPENT_PROPERTY_UTIL'),0)
        a=a+stats.stat_get_int(gameplay.get_hash_key('MP1_MONEY_SPENT_PROPERTY_UTIL'),0)
        a=a+stats.stat_get_int(gameplay.get_hash_key('MP0_MONEY_SPENT_JOB_ACTIVITY'),0)
        a=a+stats.stat_get_int(gameplay.get_hash_key('MP1_MONEY_SPENT_JOB_ACTIVITY'),0)
        a=a+stats.stat_get_int(gameplay.get_hash_key('MP0_MONEY_SPENT_CONTACT_SERVICE'),0)
        a=a+stats.stat_get_int(gameplay.get_hash_key('MP1_MONEY_SPENT_CONTACT_SERVICE'),0)
        a=a+stats.stat_get_int(gameplay.get_hash_key('MP0_MONEY_SPENT_HEALTHCARE'),0)
        a=a+stats.stat_get_int(gameplay.get_hash_key('MP1_MONEY_SPENT_HEALTHCARE'),0)
        a=a+stats.stat_get_int(gameplay.get_hash_key('MP0_MONEY_SPENT_DROPPED_STOLEN'),0)
        a=a+stats.stat_get_int(gameplay.get_hash_key('MP1_MONEY_SPENT_DROPPED_STOLEN'),0)
        a=a+stats.stat_get_int(gameplay.get_hash_key('MP0_MONEY_SPENT_SHARED'),0)
        a=a+stats.stat_get_int(gameplay.get_hash_key('MP1_MONEY_SPENT_SHARED'),0)
        a=a+stats.stat_get_int(gameplay.get_hash_key('MP0_MONEY_SPENT_JOBSHARED'),0)
        a=a+stats.stat_get_int(gameplay.get_hash_key('MP1_MONEY_SPENT_JOBSHARED'),0)
        local b=stats.stat_get_int(gameplay.get_hash_key('MP0_MONEY_EARN_JOBS'),0)
        b=b+stats.stat_get_int(gameplay.get_hash_key('MP1_MONEY_EARN_JOBS'),0)
        b=b+stats.stat_get_int(gameplay.get_hash_key('MP0_MONEY_EARN_SELLING_VEH'),0)
        b=b+stats.stat_get_int(gameplay.get_hash_key('MP1_MONEY_EARN_SELLING_VEH'),0)
        b=b+stats.stat_get_int(gameplay.get_hash_key('MP0_MONEY_EARN_BETTING'),0)
        b=b+stats.stat_get_int(gameplay.get_hash_key('MP1_MONEY_EARN_BETTING'),0)
        b=b+stats.stat_get_int(gameplay.get_hash_key('MP0_MONEY_EARN_GOOD_SPORT'),0)
        b=b+stats.stat_get_int(gameplay.get_hash_key('MP1_MONEY_EARN_GOOD_SPORT'),0)
        b=b+stats.stat_get_int(gameplay.get_hash_key('MP0_MONEY_EARN_PICKED_UP'),0)
        b=b+stats.stat_get_int(gameplay.get_hash_key('MP1_MONEY_EARN_PICKED_UP'),0)
        b=b+stats.stat_get_int(gameplay.get_hash_key('MP0_MONEY_EARN_SHARED'),0)
        b=b+stats.stat_get_int(gameplay.get_hash_key('MP1_MONEY_EARN_SHARED'),0)
        b=b+stats.stat_get_int(gameplay.get_hash_key('MP0_MONEY_EARN_JOBSHARED'),0)
        b=b+stats.stat_get_int(gameplay.get_hash_key('MP1_MONEY_EARN_JOBSHARED'),0)
        if a>b then
            local m=a-b
            menu.notify('Your balance of payments is：'..m..'$\nThe balance of payments has been cleared for you','Universe',6,1)
            stats.stat_set_int(gameplay.get_hash_key('MP0_MONEY_EARN_JOBSHARED'),stats.stat_get_int(gameplay.get_hash_key('MP0_MONEY_EARN_JOBSHARED'),0)+m,true)
            --stats.stat_set_int(gameplay.get_hash_key('MP0_MONEY_EARN_JOBSHARED'),stats.stat_get_int(gameplay.get_hash_key('MP0_MONEY_EARN_JOBSHARED'),0)+m,true)
        else
            menu.notify('good!!!!You have no balance！','Universe',6,1)
        end
    end
)

local stat_Accuracy=menu.add_feature(
    "Hit rate[!]",
    "autoaction_value_f",
    mission_cheat.id,
    function(a)
        stats.stat_set_float(gameplay.get_hash_key('MP0_WEAPON_ACCURACY'),a.value,true)
    end
)
stat_Accuracy.min,stat_Accuracy.max,stat_Accuracy.mod=0,100000,0.1
stat_Accuracy.value=stats.stat_get_float(gameplay.get_hash_key('MP0_WEAPON_ACCURACY'),0)

local stat_kills=menu.add_feature(
    "Kill players[!]",
    "autoaction_value_i",
    mission_cheat.id,
    function(a)
        stats.stat_set_int(gameplay.get_hash_key('MPPLY_KILLS_PLAYERS'),a.value,true)
    end
)
stat_kills.min,stat_kills.max,stat_kills.mod=0,2147483647,5
stat_kills.value=stats.stat_get_int(gameplay.get_hash_key('MPPLY_KILLS_PLAYERS'),0)

local no_1=menu.add_feature(
    "Ranked No. 1 in global prestige",
    "action",
    mission_cheat.id,
    function()
        menu.notify('Modification completed','Universe',3,1)
        stats.stat_set_int(gameplay.get_hash_key('MPPLY_GLOBALXP'),1,true)
    end
)






no_1.hidden=true
clear_cash.hidden=true
clear_dead.hidden=true
cooldown_clear.hidden=true
stat_kills.hidden=true
stat_Accuracy.hidden=true
_notice=menu.add_feature(
    "Turn on the hidden function",
    "action",
    mission_cheat.id,
    function()
        if not menu.is_trusted_mode_enabled() then
            menu.notify('Turn on trust mode to enable hidden features','Universe',3,3)
        else
            menu.notify('Hidden feature is enabled','Universe',3,3)
            no_1.hidden=false
            clear_cash.hidden=false
            clear_dead.hidden=false
            cooldown_clear.hidden=false
            stat_kills.hidden=false
            stat_Accuracy.hidden=false
            _notice.hidden=true
        end
    end
    )


if menu.is_trusted_mode_enabled() then
    no_1.hidden=false
    clear_cash.hidden=false
    clear_dead.hidden=false
    cooldown_clear.hidden=false
    stat_kills.hidden=false
    stat_Accuracy.hidden=false
    _notice.hidden=true
end
_U_login_start=menu.add_feature(
    "Start welcome",
    "toggle",
    main_options.id,
    function(a)
        if a.on then
            _U_main_title.on=false
            main.name='BX Loading...'
            on_start.on=true
        end
    end
)


main_about.on=true






---------------------------Self options--------------------------

local choice_menu=menu.add_player_feature("Universe","parent",0)

_U_one_kick=menu.add_player_feature(
    "Violently kick",
    "action",
    choice_menu.id,
    function(a,pid)
        if pid~=me and not player.is_player_friend(pid) and player.is_player_valid(pid) then
            network.network_session_kick_player(pid)
            send_script_event("Netbail kick", pid, {pid, generic_player_global(pid)})
            for x=0,17 do
                send_script_event("Kick "..tostring(x), pid, {pid, generic_player_global(pid)})
            end
        end
    end
)
_U_fuck_him=menu.add_player_feature(
    "Shake the player",
    "toggle",
    choice_menu.id,
    function(a,pid)
        while a.on do
            system.yield(0)
            fire.add_explosion(player.get_player_coords(pid)-v3(0,0,30),1,false,true,99999999,player.get_player_ped(pid))
        end
    end
)

_U_ima_badman=menu.add_player_feature(
    "Framing",
    "toggle",
    choice_menu.id,
    function(a,killer)
       while a.on do
            system.yield(0)
            for pid=0,31 do
                if player.is_player_valid(pid) and not player.is_player_friend(pid)  and player.player_id() ~= pid and pid~=killer then
                    fire.add_explosion(player.get_player_coords(pid),28,true,false,99999999,player.get_player_ped(killer))
                end
            end
       end
    end
)
_U_ima_badman_invis=menu.add_player_feature(
    "Framing(silent)",
    "toggle",
    choice_menu.id,
    function(a,killer)
       while a.on do
            system.yield(0)
            for pid=0,31 do
                if player.is_player_valid(pid) and not player.is_player_friend(pid) and player.player_id() ~= pid and pid~=killer then
                    fire.add_explosion(player.get_player_coords(pid),28,false,true,0,player.get_player_ped(killer))
                end
            end
       end
    end
)
_U_killing_roll=menu.add_player_feature(
    "Killing Halo",
    "toggle",
    choice_menu.id,
    function(a,pid)
        while a.on do
            system.yield(0)
            local target_player_coords=player.get_player_coords(pid)
            local me=player.player_id()
            local my_ped=player.get_player_ped(me)
            entity.set_entity_coords_no_offset(my_ped,target_player_coords+v3(math.random(-4,4),math.random(-4,4),2))
            system.yield(0)
            entity.set_entity_rotation(my_ped,v3(0,0,target_player_coords.z-180))
            local hash_weapon = is_pz(ped.get_current_ped_weapon(my_ped))
            gameplay.shoot_single_bullet_between_coords(player.get_player_coords(player.player_id()), target_player_coords, 1, hash_weapon, my_ped, true, false, 1000)
        end
    end
)
_U_spoof=menu.add_player_feature(
    "vehicle troll",
    'toggle',
    choice_menu.id,
    function(a,pid)
        while a.on do
            system.yield(0)
            local rot=entity.get_entity_rotation(player.get_player_ped(pid))
            rot:transformRotToDir()
            rot=v3(rot.x*3,rot.y*3,rot.z*3)
            spoof_veh=vehicle.create_vehicle(3052358707,player.get_player_coords(pid)+rot,0,true,false)
            entity.set_entity_rotation(spoof_veh,entity.get_entity_rotation(player.get_player_ped(pid)))
            vehicle.set_vehicle_engine_on(spoof_veh,true,true,true)
            vehicle.set_vehicle_rocket_boost_active(spoof_veh,true)
            entity.delete_entity(spoof_veh)
        end
    end
)


_U_diaozhen=menu.add_player_feature(
    "Drop frame",
    "toggle",
    choice_menu.id,
    function(a,pid)
        if a.on then
            if a.on then
                dz_veh={}
                local my_pos=player.get_player_coords(player.player_id())
                for i=0,80 do
                    if a.on then
                    --local veh=vehicle.create_vehicle(1394036463,player.get_player_coords(player.player_id())+v3(0,0,5),0,true,true)
                        local veh=object.create_object(3026699584,player.get_player_coords(player.player_id())+v3(0,0,5),true,true)
                        dz_veh[#dz_veh+1]=veh
                        entity.attach_entity_to_entity(veh,player.get_player_ped(pid),0,v3(0,0,0),v3(0,0,0),true,false,true,0,true)
                        local veh=object.create_object(1952396163,player.get_player_coords(player.player_id())+v3(0,0,5),true,true)
                        dz_veh[#dz_veh+1]=veh
                        entity.attach_entity_to_entity(veh,player.get_player_ped(pid),0,v3(0,0,0),v3(0,0,0),true,false,true,0,true)
                        local veh=object.create_object(3222025520,player.get_player_coords(player.player_id())+v3(0,0,5),true,true)
                        dz_veh[#dz_veh+1]=veh
                        entity.attach_entity_to_entity(veh,player.get_player_ped(pid),0,v3(0,0,0),v3(0,0,0),true,false,true,0,true)
                        local veh=object.create_object(2081936690,player.get_player_coords(player.player_id())+v3(0,0,5),true,true)
                        dz_veh[#dz_veh+1]=veh
                        entity.attach_entity_to_entity(veh,player.get_player_ped(pid),0,v3(0,0,0),v3(0,0,0),true,false,true,0,true)
                    end
                end
            else
                if dz_veh then
                    for i=1,#dz_veh do
                        entity.delete_entity(dz_veh[i])
                    end
                end
            end
        end
    end
)
c_U_invi_god_items={}
c_U_invi_god=menu.add_player_feature(
    'Invisible',
    "toggle",
    choice_menu.id,
    function(a,pid)
        if a.on then
                local obj=object.create_object(1399999408,player.get_player_coords(player.player_id())+v3(0,0,5),true,true)
                entity.attach_entity_to_entity(obj,player.get_player_ped(pid),0,v3(0,0,0),v3(0,0,0),true,false,true,0,true)
                c_U_invi_god_items[#c_U_invi_god_items+1]=obj
                entity.set_entity_visible(obj,false)
            
        else
            if c_U_invi_god_items then
                for i=1,#c_U_invi_god_items do
                    entity.delete_entity(c_U_invi_god_items[i])
                end
            end
        end
    end
)






-------------------------------------------------------------------------------------------------保存设置
-------------------------------------------------------------------------------------------------保存设置
-------------------------------------------------------------------------------------------------保存设置
-------------------------------------------------------------------------------------------------保存设置
-------------------------------------------------------------------------------------------------保存设置
-------------------------------------------------------------------------------------------------保存设置
-------------------------------------------------------------------------------------------------保存设置
-------------------------------------------------------------------------------------------------保存设置
-------------------------------------------------------------------------------------------------保存设置
-------------------------------------------------------------------------------------------------保存设置
-------------------------------------------------------------------------------------------------保存设置
-------------------------------------------------------------------------------------------------保存设置
-------------------------------------------------------------------------------------------------保存设置
-------------------------------------------------------------------------------------------------保存设置
-------------------------------------------------------------------------------------------------保存设置
-------------------------------------------------------------------------------------------------保存设置
-------------------------------------------------------------------------------------------------保存设置
-------------------------------------------------------------------------------------------------保存设置

--查询方法
local function wt_func_state(__func)
    return tostring(__func.on)
end
local _funcs_name={
    '_U_title_players',
    '_U_health_cheat',
    '_U_time_go_back',
    'get_host',
    'is_host',
    'kick',
    '_U_sms_cheat',
    '_U_Anti_MK2',
    '_U_Anti_MK1',
    '_U_force_kick=',
    '_U_killing_eye_v1',
    '_U_killing_eye_v2',
    '_U_killing_eye_v3',
    '_U_invis_shield',
    '_U_invis_shield_v2',
    '_U_invis_shield_v3',
    '_U_fast_respawn',
    '_U_vehicle_driver_weapon',
    '_U_rope_weapon',
    '_U_fast_shooter',
    '_U_freeze_session',
    '_U_fuck_session',
    '_U_fuck_session2',
    '_U_ad_m',
    '_U_ozark_title',
    '_U_time_title',
    '_U_host_info',
    '_U_fuck_them',
    '_U_Chat_trial',
    '_U_anti_scrpit',
    '_U_fuck_myself',
    '_U_fuck_spectater',
    '_U_Anti_spectater',
    '_U_main_weapon_color',
    '_U_speed_fire_veh',
    '_U_unlock_max_speed',
    '_U_veh_boost',
    '_U_veh_boost_infinity',
    '_U_veh_auto_boost',
    '_U_main_weapon_switch',
    '_U_main_auto_skip',
    '_U_clear_notice',
    '_U_Anti_Npc',
    '_U_Anti_Npc_Aim_Shoot',
    '_U_make_NPC_Fire',
    '_U_login_start',
    '_U_fire_fist',
    '_U_Anti_aim',
    '_U_main_title',
    '_U_spin',
    '_U_spin_16',
    '_U_vehicle_flier',
    '_U_protect_shield',
    '_U_cai_dan_alien',
    '_U_DT',
    '_U_walk_on_water',
    '_U_fix_walk_on_water',
    '_U_veh_on_water',
    '_U_fix_drive_on_water',
    '_U_firework_gun',
    '_U_send_block_msg',
    '_U_invi_god'
}
local _funcs={}
_funcs['_U_title_players']=_U_title_players
_funcs['_U_health_cheat']=_U_health_cheat
_funcs['_U_time_go_back']=_U_time_go_back
_funcs['get_host']=_U_get_host
_funcs['is_host']=_U_is_host
_funcs['kick']=_U_kick
_funcs['_U_sms_cheat']=_U_sms_cheat
_funcs['_U_Anti_MK2']=_U_Anti_MK2
_funcs['_U_Anti_MK1']=_U_Anti_MK1
_funcs['_U_force_kick=']=_U_force_kick
_funcs['_U_killing_eye_v1']=_U_killing_eye_v1
_funcs['_U_killing_eye_v2']=_U_killing_eye_v2
_funcs['_U_killing_eye_v3']=_U_killing_eye_v3
_funcs['_U_invis_shield']=_U_invis_shield
_funcs['_U_invis_shield_v2']=_U_invis_shield_v2
_funcs['_U_invis_shield_v3']=_U_invis_shield_v3
_funcs['_U_fast_respawn']=_U_fast_respawn
_funcs['_U_vehicle_driver_weapon']=_U_vehicle_driver_weapon
_funcs['_U_rope_weapon']=_U_rope_weapon
_funcs['_U_fast_shooter']=_U_fast_shooter
_funcs['_U_freeze_session']=_U_freeze_session
_funcs['_U_fuck_session']=_U_fuck_session
_funcs['_U_fuck_session2']=_U_fuck_session2
_funcs['_U_ad_m']=_U_ad_m
_funcs['_U_ozark_title']=_U_ozark_title
_funcs['_U_time_title']=_U_time_title
_funcs['_U_host_info']=_U_host_info
_funcs['_U_fuck_them']=_U_fuck_them
_funcs['_U_Chat_trial']=_U_Chat_trial
_funcs['_U_anti_scrpit']=_U_anti_scrpit
_funcs['_U_fuck_myself']=_U_fuck_myself
_funcs['_U_fuck_spectater']=_U_fuck_spectater
_funcs['_U_Anti_spectater']=_U_Anti_spectater
_funcs['_U_main_weapon_color']=_U_main_weapon_color
_funcs['_U_speed_fire_veh']=_U_speed_fire_veh
_funcs['_U_unlock_max_speed']=_U_unlock_max_speed
_funcs['_U_veh_boost']=_U_veh_boost
_funcs['_U_veh_boost_infinity']=_U_veh_boost_infinity
_funcs['_U_veh_auto_boost']=_U_veh_auto_boost
_funcs['_U_main_weapon_switch']=_U_main_weapon_switch
_funcs['_U_main_auto_skip']=_U_main_auto_skip
_funcs['_U_clear_notice']=_U_clear_notice
_funcs['_U_Anti_Npc']=_U_Anti_Npc
_funcs['_U_Anti_Npc_Aim_Shoot']=_U_Anti_Npc_Aim_Shoot
_funcs['_U_make_NPC_Fire']=_U_make_NPC_Fire
_funcs['_U_login_start']=_U_login_start
_funcs['_U_fire_fist']=_U_fire_fist
_funcs['_U_Anti_aim']=_U_Anti_aim
_funcs['_U_main_title']=_U_main_title
_funcs['spin_little']=spin_little
_funcs['_U_spin']=_U_spin
_funcs['_U_spin_16']=_U_spin_16
_funcs['_U_vehicle_flier']=_U_vehicle_flier
_funcs['_U_protect_shield']=_U_protect_shield
_funcs['_U_cai_dan_alien']=_U_cai_dan_alien
_funcs['_U_DT']=_U_DT
_funcs['_U_walk_on_water']=_U_walk_on_water
_funcs['_U_fix_walk_on_water']=_U_fix_walk_on_water
_funcs['_U_fix_drive_on_water']=_U_fix_drive_on_water
_funcs['_U_veh_on_water']=_U_veh_on_water
_funcs['_U_firework_gun']=_U_firework_gun
_funcs['_U_send_block_msg']=_U_send_block_msg
_funcs['_U_invi_god']=_U_invi_god



local save_options=menu.add_feature(
    "Save Settings",
    "action",
    main_options.id,
    function(a)
        need_write_msg=''
        menu.notify('Save completed','Universe',4,6)
        local file=io.open(utils.get_appdata_path("PopstarDevs", "").."\\2Take1Menu\\cfg\\Universe_Options.cfg","w")
            for i=1,#_funcs_name do
                if need_write_msg=='' then
                    if _funcs[_funcs_name[i]].type==1 then
                        need_write_msg=_funcs_name[i]..'='..wt_func_state(_funcs[_funcs_name[i]])
                    elseif _funcs[_funcs_name[i]].type==35 or _funcs[_funcs_name[i]].type==7 then
                        need_write_msg=_funcs_name[i]..'='..wt_func_state(_funcs[_funcs_name[i]])..'\n'.._funcs_name[i]..'='.._funcs[_funcs_name[i]].value
                    end
                else
                    if _funcs[_funcs_name[i]].type==1 then
                        need_write_msg=need_write_msg..'\n'.._funcs_name[i]..'='..wt_func_state(_funcs[_funcs_name[i]])
                    elseif _funcs[_funcs_name[i]].type==35 or _funcs[_funcs_name[i]].type==7 then
                        need_write_msg=need_write_msg..'\n'.._funcs_name[i]..'='..wt_func_state(_funcs[_funcs_name[i]])..'\n'.._funcs_name[i]..'='.._funcs[_funcs_name[i]].value
                    end
                    
                end
                --print(_funcs[_funcs_name[i]].type)
            end
        file:write(need_write_msg)
        file:close()
    end
)

local function run_func(func,state)
    if tostring(state)=='true' then
        _funcs[func].on=true
    elseif tostring(state)~='false' then
        _funcs[func].value=tonumber(state)
    end
end


local run_options=menu.add_feature(
    "Run settings",
    'action',
    main_options.id,
    function(a)
        if a.on then
            if utils.file_exists(utils.get_appdata_path("PopstarDevs", "").."\\2Take1Menu\\cfg\\Universe_Options.cfg") then
                local file=io.open(utils.get_appdata_path("PopstarDevs", "").."\\2Take1Menu\\cfg\\Universe_Options.cfg",'r')
                for i in file:lines() do
                    run_func(i:split('=')[1],i:split('=')[2])
                end
                file:close()
            end
        end
    end
)
run_options.threaded=true
run_options.hidden=true

run_options.on=true





























































-------------------------------------------------------------------------------------------------保存设置
-------------------------------------------------------------------------------------------------保存设置
-------------------------------------------------------------------------------------------------保存设置
-------------------------------------------------------------------------------------------------保存设置
-------------------------------------------------------------------------------------------------保存设置
-------------------------------------------------------------------------------------------------保存设置
-------------------------------------------------------------------------------------------------保存设置
-------------------------------------------------------------------------------------------------保存设置
-------------------------------------------------------------------------------------------------保存设置
-------------------------------------------------------------------------------------------------保存设置
-------------------------------------------------------------------------------------------------保存设置
-------------------------------------------------------------------------------------------------保存设置
-------------------------------------------------------------------------------------------------保存设置
-------------------------------------------------------------------------------------------------保存设置
-------------------------------------------------------------------------------------------------保存设置
-------------------------------------------------------------------------------------------------保存设置
-------------------------------------------------------------------------------------------------保存设置
-------------------------------------------------------------------------------------------------保存设置





























-------------------------抢劫------------------------
local function stat_set_int(hash, prefix, value, save)
    save = save or true
    local hash0, hash1 = hash
    if prefix then
        hash0 = "MP0_" .. hash
        hash1 = "MP1_" .. hash
        hash1 = gameplay.get_hash_key(hash1)
    end
    hash0 = gameplay.get_hash_key(hash0)
    local value0, e = stats.stat_get_int(hash0, -1)
    if value0 ~= value then
        stats.stat_set_int(hash0, value, save)
    end
    if prefix then
        local value1, e = stats.stat_get_int(hash1, -1)
        if value1 ~= value then
            stats.stat_set_int(hash1, value, save)
        end
    end
end
-- BOOL
local function stat_set_bool(hash, prefix, value, save)
    save = save or true
    local hash0, hash1 = hash
    if prefix then
        hash0 = "MP0_" .. hash
        hash1 = "MP1_" .. hash
        hash1 = gameplay.get_hash_key(hash1)
    end
    hash0 = gameplay.get_hash_key(hash0)
    local value0, e = stats.stat_get_bool(hash0, -1)
    if value0 ~= value then
        stats.stat_set_bool(hash0, value, save)
    end
    if prefix then
        local value1, e = stats.stat_get_bool(hash1, -1)
        if value1 ~= value then
            stats.stat_set_bool(hash1, value, save)
        end
    end
end


local PERICO_HEIST = menu.add_feature("Cayo Perico Heist", "parent", Heist_Control.id)
local CAYO_AUTO_PRST = menu.add_feature("Automated Presets", "parent", PERICO_HEIST.id, function()
menu.notify("- Remember to choose your preset outside the Submarine or in the Main Deck\n\n- Remember to deactivate the preset at the end.", "", 6, 0x50F0FF14)
end)
local NON_EVENT = menu.add_feature("Common Presets [Payout $2.5 Millions]", "parent", CAYO_AUTO_PRST.id)
local AUTOMATED_SOLO = menu.add_feature("SOLO  $2.4 MILLIONs", "parent", NON_EVENT.id)
local AUTOMATED_2P = menu.add_feature("2 Players  $2.4 MILLIONs", "parent", NON_EVENT.id)
local AUTOMATED_3P = menu.add_feature("3 Players  $2.4 MILLIONs", "parent", NON_EVENT.id)
local AUTOMATED_4P = menu.add_feature("4 Players  $2.4 MILLIONs", "parent", NON_EVENT.id)
--
local WEEKLY_PRESET = menu.add_feature("Weekly Event Presets [Payout $4.1 Millions]", "parent", CAYO_AUTO_PRST.id, function()
menu.notify("Weekly Event Presets should only be used when actually activated by Rockstar\n\nTo make sure the event is activated\nVisit:\nwww.rockstargames.com/newswire", "", 6, 0x50F0FF14)
end)
local WEEKLY_SOLO = menu.add_feature("SOLO  $4.1 MILLIONs", "parent", WEEKLY_PRESET.id)
local WEEKLY_F2 = menu.add_feature("2 Players  $4.1 MILLIONs", "parent", WEEKLY_PRESET.id)
local WEEKLY_F3 = menu.add_feature("3 Players  $4.1 MILLIONs", "parent", WEEKLY_PRESET.id)
local WEEKLY_F4 = menu.add_feature("4 Players  $4.1 MILLIONs", "parent", WEEKLY_PRESET.id)
local STANDARD_SET = menu.add_feature("Standard Preset", "parent", PERICO_HEIST.id, function()
menu.notify("- Remember to choose your preset outside the Submarine or in the Main Deck\n\n- Remember to deactivate the preset at the end.", "", 6, 0x50F0FF14)
end)
local TELEPORT = menu.add_feature("Custom Teleport", "parent", PERICO_HEIST.id)
local PERICO_ADV = menu.add_feature("Advanced Features", "parent", PERICO_HEIST.id)
local HSCUT_CP = menu.add_feature("Players Payments", "parent", PERICO_ADV.id, function()
menu.notify("Adding such a high percentage can affect your payment (not getting paid)", "", 5, 0x6414F0FF)
end)
-- local PERICO_HOST_CUT = menu.add_feature("Your Payment", "parent", HSCUT_CP.id)
-- local PERICO_P2_CUT = menu.add_feature("Player 2 Payment", "parent", HSCUT_CP.id)
-- local PERICO_P3_CUT = menu.add_feature("Player 3 Payment", "parent", HSCUT_CP.id)
-- local PERICO_P4_CUT = menu.add_feature("Player 4 Payment", "parent", HSCUT_CP.id)
-- local CAYO_BAG = menu.add_feature("Change Bag Capacity", "parent", PERICO_ADV.id)
local CAYO_VEHICLES = menu.add_feature("Approach Vehicles", "parent", PERICO_HEIST.id)
local CAYO_PRIMARY = menu.add_feature("Primary Target", "parent", PERICO_HEIST.id)
local CAYO_SECONDARY = menu.add_feature("Secondary Target", "parent", PERICO_HEIST.id)
local CAYO_WEAPONS = menu.add_feature("Weapon Loadouts", "parent", PERICO_HEIST.id)
local CAYO_EQUIPM = menu.add_feature("Equipments Spawn Location", "parent", PERICO_HEIST.id)
local CAYO_TRUCK = menu.add_feature("Supply Truck Location", "parent", PERICO_HEIST.id)
local CAYO_DFFCTY = menu.add_feature("Heist Difficulty", "parent", PERICO_HEIST.id)
local MORE_OPTIONS = menu.add_feature("»More", "parent", PERICO_HEIST.id)
local CASINO_HEIST = menu.add_feature("Diamond Casino Heist", "parent", Heist_Control.id)
local CASINO_PRESETS = menu.add_feature("Insta-Play [Presets]", "parent", CASINO_HEIST.id, function()
menu.notify("Remember\nYou must pay to start the heist, then go outside the arcade/garage to apply the preset correctly!", "", 6, 0x64FF78B4)
end)
local CAH_ADVCED = menu.add_feature("Advanced Features", "parent", CASINO_HEIST.id)
local TELEPORT_CAH = menu.add_feature("Custom Teleport", "parent", CASINO_HEIST.id)
local CASINO_BOARD1 = menu.add_feature("Heist Planning [Board 1]", "parent", CASINO_HEIST.id)
local BOARD1_APPROACH = menu.add_feature("Change Approach and Difficulty", "parent", CASINO_BOARD1.id)
local CASINO_TARGET = menu.add_feature("Change Target", "parent", CASINO_BOARD1.id)
local CASINO_BOARD2 = menu.add_feature("Heist Planning [Board 2]", "parent", CASINO_HEIST.id)
local CASINO_BOARD3 = menu.add_feature("Heist Planning [Board 3]", "parent", CASINO_HEIST.id)
local CASINO_LBOARDS = menu.add_feature("Load/Unload : Boards", "parent", CASINO_HEIST.id)
local CASINO_MORE = menu.add_feature("»More", "parent", CASINO_HEIST.id)
local DOOMS_HEIST = menu.add_feature("Doomsday Heist", "parent", Heist_Control.id)
local DOOMS_PRESETS = menu.add_feature("Insta-Play [Presets]", "parent", DOOMS_HEIST.id)
local TELEPORT_DOOMS = menu.add_feature("Custom Teleport", "parent", DOOMS_HEIST.id)
local DDHEIST_PLYR_MANAGER = menu.add_feature("Players Payments", "parent", DOOMS_HEIST.id)
local CLASSIC_HEISTS = menu.add_feature("Classic Heists", "parent", Heist_Control.id)
-- local CLASSIC_CUT = menu.add_feature("Your Payment (As Host)", "parent", CLASSIC_HEISTS.id)
local LS_ROBBERY = menu.add_feature("LS Tuners Robbery", "parent", Heist_Control.id)
--local TELEP_CZM = menu.add_feature("Other teleports", "parent", Heist_Control.id)

-- CAYO CUSTOM TELEPORT
menu.add_feature("Kosatka : Heist Board [Call Kosatka first]", "action", TELEPORT.id, function()
    menu.notify("If you teleport without calling it, you will be bugged", "", 4, 0x64F06414)
	pedmy = player.get_player_ped(player.player_id())
	entity.set_entity_coords_no_offset(pedmy,v3(1561.224,386.659,-49.685))
end)

menu.add_feature("Kosatka : Main Deck [Call Kosatka first]", "action", TELEPORT.id, function()
    menu.notify("If you teleport without calling it, you will be bugged", "", 4, 0x64F06414)
	pedmy = player.get_player_ped(player.player_id())
	entity.set_entity_coords_no_offset(pedmy,v3(1563.218,406.030,-49.667))
end)

menu.add_feature("Drainage Tunnel : Entrance", "action", TELEPORT.id, function()
    menu.notify("Teleported to Drainage Tunnel : Entrance", "", 4, 0x64F06414)
    if player.is_player_in_any_vehicle ~= -1 then do
    pedmy = player.get_player_vehicle(player.player_id())
    entity.set_entity_coords_no_offset(pedmy,v3(5044.726,-5816.164,-11.213))
    if player.is_player_in_any_vehicle ~= 0 then do
	pedmy = player.get_player_ped(player.player_id())
	entity.set_entity_coords_no_offset(pedmy,v3(5044.726,-5816.164,-11.213))
    return HANDLER_POP end end end end
end)

menu.add_feature("Drainage Tunnel : 2nd Checkpoint", "action", TELEPORT.id, function()
    menu.notify("Teleported to Drainage Tunnel : 2nd Checkpoint", "", 4, 0x64F06414)
	pedmy = player.get_player_ped(player.player_id())
	entity.set_entity_coords_no_offset(pedmy,v3(5054.630,-5771.519,-4.807))
end)

menu.add_feature("Main Target : Room", "action", TELEPORT.id, function()
    menu.notify("Teleported to Main Target", "", 4, 0x64F06414)
	pedmy = player.get_player_ped(player.player_id())
	entity.set_entity_coords_no_offset(pedmy,v3(5006.896,-5755.963,15.487))
end)

menu.add_feature("Secondary Target : Room", "action", TELEPORT.id, function()
    menu.notify("Teleported to Secondary Target room", "", 4, 0x64F06414)
	pedmy = player.get_player_ped(player.player_id())
	entity.set_entity_coords_no_offset(pedmy,v3(5003.467,-5749.352,14.840))
end)

menu.add_feature("Vault : El Rubio Office", "action", TELEPORT.id, function()
    menu.notify("Teleported to Vault", "", 4, 0x64F06414)
	pedmy = player.get_player_ped(player.player_id())
	entity.set_entity_coords_no_offset(pedmy,v3(5010.753,-5757.639,28.845))
end)

menu.add_feature("Reduct : Escape Gate", "action", TELEPORT.id, function()
    menu.notify("Teleported to Exit", "", 4, 0x64F06414)
	pedmy = player.get_player_ped(player.player_id())
	entity.set_entity_coords_no_offset(pedmy,v3(4992.854,-5718.537,19.880))
end)

menu.add_feature("Ocean : Safe Place", "action", TELEPORT.id, function()
    menu.notify("Teleported to Ocean", "", 4, 0x64F06414)
    if player.is_player_in_any_vehicle ~= 1 then do
    pedmy = player.get_player_vehicle(player.player_id())
    entity.set_entity_coords_no_offset(pedmy,v3(4771.792,-6166.055,-40.266))
    if player.is_player_in_any_vehicle ~= 0 then do
    pedmy = player.get_player_ped(player.player_id())
    entity.set_entity_coords_no_offset(pedmy,v3(4771.792,-6166.055,-40.266))
    return end end end end
end)
-- CASINO CUSTOM TELEPORT

menu.add_feature("Planning Boards", "action", TELEPORT_CAH.id, function()
    menu.notify("Teleported sucessfully", "", 4, 0x64F06414)
	pedmy = player.get_player_ped(player.player_id())
	entity.set_entity_coords_no_offset(pedmy,v3(2711.773,-369.458,-54.781))
end)

menu.add_feature("Garagem Exit", "action", TELEPORT_CAH.id, function()
    menu.notify("Teleported sucessfully", "", 4, 0x64F06414)
	pedmy = player.get_player_ped(player.player_id())
	entity.set_entity_coords_no_offset(pedmy,v3(2677.237,-361.494,-55.187))
end)
-- DOOMSDAY CUSTOM TELEPORT

menu.add_feature("Photo screen : Heist board (ACT II)", "action", TELEPORT_DOOMS.id, function()
    menu.notify("Teleported sucessfully", "", 4, 0x64F06414)
	pedmy = player.get_player_ped(player.player_id())
	entity.set_entity_coords_no_offset(pedmy,v3(515.528,4835.353,-62.587))
end)

menu.add_feature("Prisoner cell (ACT II)", "action", TELEPORT_DOOMS.id, function()
    menu.notify("Teleported sucessfully", "", 4, 0x64F06414)
	pedmy = player.get_player_ped(player.player_id())
	entity.set_entity_coords_no_offset(pedmy,v3(512.888,4833.033,-68.989))
end)

do
    menu.add_feature("About", "action", Heist_Control.id, function()
    menu.notify("Thanks to\n\n\thaekkzer\n\tkektram\n\tProddy\n\t2TAKE1 Menu Devs\n\n Thanks E.#7777 (Donor)", "", 7, 0x64F06414)
    menu.notify("Unique Developer: jhowkNx\n\nFor future updates, visit:\ngithub.com/jhowkNx/Heist-Control-v2", "Heist Control - Official Page", 7, 0x64F06414)
    end)
end
----------------------------------------------------------------
---- AUTO (ALL PLAYERS) NO SECONDARY TARGET
do
local QUICK_SET_ANY = {
    {"",},
    {"H4CNF_BS_GEN", 262143},
    {"H4CNF_BS_ENTR", 63},
    {"H4CNF_BS_ABIL", 63},
    {"H4CNF_WEP_DISRP", 3},
    {"H4CNF_ARM_DISRP", 3},
    {"H4CNF_HEL_DISRP", 3},
    {"H4CNF_BOLTCUT", 4424},
    {"H4CNF_UNIFORM", 5256},
    {"H4CNF_GRAPPEL", 5156},
    {"H4CNF_APPROACH", 0xFFFFFFF},
    {"H4LOOT_CASH_I", 0},
    {"H4LOOT_CASH_C", 0},
    {"H4LOOT_WEED_I", 0},
    {"H4LOOT_WEED_C", 0},
    {"H4LOOT_COKE_I", 0},
    {"H4LOOT_COKE_C", 0},
    {"H4LOOT_GOLD_I", 0},
    {"H4LOOT_GOLD_C", 0},
    {"H4LOOT_PAINT", 0},
    {"H4LOOT_CASH_V", 0},
    {"H4LOOT_COKE_V", 0},
    {"H4LOOT_GOLD_V", 0},
    {"H4LOOT_PAINT_V", 0},
    {"H4LOOT_WEED_V", 0},
    {"H4LOOT_CASH_I_SCOPED", 0},
    {"H4LOOT_CASH_C_SCOPED", 0},
    {"H4LOOT_WEED_I_SCOPED", 0},
    {"H4LOOT_WEED_C_SCOPED", 0},
    {"H4LOOT_COKE_I_SCOPED", 0},
    {"H4LOOT_COKE_C_SCOPED", 0},
    {"H4LOOT_GOLD_I_SCOPED", 0},
    {"H4LOOT_GOLD_C_SCOPED", 0},
    {"H4LOOT_PAINT_SCOPED", 0},
    {"H4CNF_TARGET", 5},
    {"H4CNF_WEAPONS", 1},
    {"H4_MISSIONS", 65283},
    {"H4_PROGRESS", 126823},
    {"H4_PLAYTHROUGH_STATUS", 5}
}
menu.add_feature("Quick Preset (1-4) $2.4MI [Main Target only]", "toggle", NON_EVENT.id, function(quickcp)
    menu.notify("Information\n\n- There are no secondary targets, your goal is just to steal the primary target and escape\n\n- There are no other vehicles available besides the Kosatka\n\n- Do not mess with the percentage or targets\n\n- Disable only at end of heist", "Heist Control", 15, 0x64F06414)
    menu.notify("Note: This preset has a visual bug that shows an unusual amount at the end of the heist, however if you look in online players you can verify the true payment of other members.", "", 10, 0x501400FF)
    while quickcp.on do
        for i = 1, #QUICK_SET_ANY do
        stat_set_int(QUICK_SET_ANY[i][1], true, QUICK_SET_ANY[i][2])
        end
        script.set_global_i(1711169,100) -- original version 1710289 + 823 + 56 + 1
        script.set_global_i(1711170,145) -- original version 1710289 + 823 + 56 + 2
        script.set_global_i(1711171,145) -- original version 1710289 + 823 + 56 + 3
        script.set_global_i(1711172,145) -- original version 1710289 + 823 + 56 + 4
        script.set_global_f(262145+29470,0.0)
        script.set_global_f(262145+29471,0.0)
        script.set_global_i(262145 + 29466,2455000)
    if not quickcp.on then return end
    system.wait(0)
    end
end)
end

-- WEEKLY EVENT QUICK METHOD
do
    local WEAKLY_QUICK = {
        {"",},
        {"H4CNF_BS_GEN", 262143},
        {"H4CNF_BS_ENTR", 63},
        {"H4CNF_BS_ABIL", 63},
        {"H4CNF_WEP_DISRP", 3},
        {"H4CNF_ARM_DISRP", 3},
        {"H4CNF_HEL_DISRP", 3},
        {"H4CNF_BOLTCUT", 4424},
        {"H4CNF_UNIFORM", 5256},
        {"H4CNF_GRAPPEL", 5156},
        {"H4CNF_APPROACH", 0xFFFFFFF},
        {"H4LOOT_CASH_I", 0},
        {"H4LOOT_CASH_C", 0},
        {"H4LOOT_WEED_I", 0},
        {"H4LOOT_WEED_C", 0},
        {"H4LOOT_COKE_I", 0},
        {"H4LOOT_COKE_C", 0},
        {"H4LOOT_GOLD_I", 0},
        {"H4LOOT_GOLD_C", 0},
        {"H4LOOT_PAINT", 0},
        {"H4LOOT_CASH_V", 0},
        {"H4LOOT_COKE_V", 0},
        {"H4LOOT_GOLD_V", 0},
        {"H4LOOT_PAINT_V", 0},
        {"H4LOOT_WEED_V", 0},
        {"H4LOOT_CASH_I_SCOPED", 0},
        {"H4LOOT_CASH_C_SCOPED", 0},
        {"H4LOOT_WEED_I_SCOPED", 0},
        {"H4LOOT_WEED_C_SCOPED", 0},
        {"H4LOOT_COKE_I_SCOPED", 0},
        {"H4LOOT_COKE_C_SCOPED", 0},
        {"H4LOOT_GOLD_I_SCOPED", 0},
        {"H4LOOT_GOLD_C_SCOPED", 0},
        {"H4LOOT_PAINT_SCOPED", 0},
        {"H4CNF_TARGET", 5},
        {"H4CNF_WEAPONS", 1},
        {"H4_MISSIONS", 65283},
        {"H4_PROGRESS", 126823},
        {"H4_PLAYTHROUGH_STATUS", 5}
    }
    menu.add_feature("Quick Preset (1-4) $4.1MI [Main Target only]", "toggle", WEEKLY_PRESET.id, function(quickSET)
        menu.notify("Information\n\n- There are no secondary targets, your goal is just to steal the primary target and escape\n\n- There are no other vehicles available besides the Kosatka\n\n- Do not mess with the percentage or targets\n\n- Disable only at end of heist", "Heist Control", 15, 0x64F06414)
        menu.notify("Note: This preset has a visual bug that shows an unusual amount at the end of the heist, however if you look in online players you can verify the true payment of other members.", "", 10, 0x501400FF)
        while quickSET.on do
            for i = 1, #WEAKLY_QUICK do
            stat_set_int(WEAKLY_QUICK[i][1], true, WEAKLY_QUICK[i][2])
            end
            script.set_global_i(1711169,100) -- original version 1710289 + 823 + 56 + 1
            script.set_global_i(1711170,145) -- original version 1710289 + 823 + 56 + 2
            script.set_global_i(1711171,145) -- original version 1710289 + 823 + 56 + 3
            script.set_global_i(1711172,145) -- original version 1710289 + 823 + 56 + 4
            script.set_global_f(262145+29470,0.0)
            script.set_global_f(262145+29471,0.0)
            script.set_global_i(262145 + 29466,4025000)
        if not quickSET.on then return end
        system.wait(0)
        end
    end)
    end

--- CAYO AUTOMATED PRESET SOLO PLAYER
do
local AUTO_SOLO_SAPPHIRE_HARD = {
    {"",},
    {"H4CNF_TARGET", 5},
    {"H4LOOT_CASH_I", 5551206},
    {"H4LOOT_CASH_I_SCOPED", 5551206},
    {"H4LOOT_CASH_C", 0},
    {"H4LOOT_CASH_C_SCOPED", 0},
    {"H4LOOT_COKE_I", 4884838},
    {"H4LOOT_COKE_I_SCOPED", 4884838},
    {"H4LOOT_COKE_C", 0},
    {"H4LOOT_COKE_C_SCOPED", 0},
    {"H4LOOT_GOLD_I", 0},
    {"H4LOOT_GOLD_I_SCOPED", 0},
    {"H4LOOT_GOLD_C", 192},
    {"H4LOOT_GOLD_C_SCOPED", 192},
    {"H4LOOT_WEED_I", 0},
    {"H4LOOT_WEED_I_SCOPED", 0},
    {"H4LOOT_WEED_C", 0},
    {"H4LOOT_WEED_C_SCOPED", 0},
    {"H4LOOT_PAINT", 120},
    {"H4LOOT_PAINT_SCOPED", 120},
    {"H4LOOT_CASH_V", 224431},
    {"H4LOOT_COKE_V", 353863},
    {"H4LOOT_GOLD_V", 471817},
    {"H4LOOT_PAINT_V", 353863},
    {"H4LOOT_WEED_V", 0},
        --
    {"H4_PROGRESS", 131055}, --hard
    {"H4CNF_BS_GEN", 0xFFFFFFF},
    {"H4CNF_BS_ENTR", 0xFFFFFFF},
    {"H4CNF_BS_ABIL", 0xFFFFFFF},
    {"H4CNF_WEP_DISRP", 3},
    {"H4CNF_ARM_DISRP", 3},
    {"H4CNF_HEL_DISRP", 3},
    {"H4CNF_APPROACH", 0xFFFFFFF}
}

local USER_CAN_MDFY_PRESET_AUTO_SPSOLO = {
    {"",},
    {"H4CNF_BOLTCUT", 0xFFFFFFF},
    {"H4CNF_UNIFORM", 0xFFFFFFF},
    {"H4CNF_GRAPPEL", 0xFFFFFFF},
    {"H4_MISSIONS", 0xFFFFFFF},
    {"H4CNF_WEAPONS", 1},
    {"H4CNF_TROJAN", 5},
    {"H4_PLAYTHROUGH_STATUS", 100}
}
    menu.add_feature("Sapphire Panther", "toggle", AUTOMATED_SOLO.id, function(SOLO_SAPH_var0)
    menu.notify("Preset modified to SOLO\n- Don't use any advanced options\n- Don't use bag modifier\n- Don't change the percentage set by the script\n- Fill the bag\n\n- Leave this option enabled until you finish the Heist", "Cayo Perico SOLO | Sapphire Panther", 7, 0xffcc63a6)
        for i = 1, #USER_CAN_MDFY_PRESET_AUTO_SPSOLO do
        stat_set_int(USER_CAN_MDFY_PRESET_AUTO_SPSOLO[i][1], true, USER_CAN_MDFY_PRESET_AUTO_SPSOLO[i][2])
        end
        while SOLO_SAPH_var0.on do
        for i = 1, #AUTO_SOLO_SAPPHIRE_HARD do
        stat_set_int(AUTO_SOLO_SAPPHIRE_HARD[i][1], true, AUTO_SOLO_SAPPHIRE_HARD[i][2])
        end
        script.set_global_f(262145+29470,-0.1) --pavel cut protection
        script.set_global_f(262145+29471,-0.02) --fency fee cut protection
        script.set_global_i(262145+29227,1800) -- bag protection
        script.set_global_i(1711169,100) -- original version 1710289 + 823 + 56 + 1
        if not SOLO_SAPH_var0.on then return end
        system.wait(0)
    end
end)
end

---- SOLO RUBY
--- CAYO AUTOMATED PRESET SOLO
do
local AUTO_SOLO_RUBY_HARD = {
    {"",},
    {"H4CNF_TARGET", 1},
    {"H4LOOT_CASH_I", 9208137},
    {"H4LOOT_CASH_I_SCOPED", 9208137},
    {"H4LOOT_CASH_C", 0},
    {"H4LOOT_CASH_C_SCOPED", 0},
    {"H4LOOT_COKE_I", 1048704},
    {"H4LOOT_COKE_I_SCOPED", 1048704},
    {"H4LOOT_COKE_C", 0},
    {"H4LOOT_COKE_C_SCOPED", 0},
    {"H4LOOT_GOLD_I", 0},
    {"H4LOOT_GOLD_I_SCOPED", 0},
    {"H4LOOT_GOLD_C", 255},
    {"H4LOOT_GOLD_C_SCOPED", 255},
    {"H4LOOT_WEED_I", 4206596},
    {"H4LOOT_WEED_I_SCOPED", 4206596},
    {"H4LOOT_WEED_C", 0},
    {"H4LOOT_WEED_C_SCOPED", 0},
    {"H4LOOT_PAINT", 127},
    {"H4LOOT_PAINT_SCOPED", 127},
    {"H4LOOT_CASH_V", 424431},
    {"H4LOOT_COKE_V", 848863},
    {"H4LOOT_GOLD_V", 1131817},
    {"H4LOOT_PAINT_V", 848863},
    {"H4LOOT_WEED_V", 679090},
    --
    {"H4_PROGRESS", 131055}, --hard
    {"H4CNF_BS_GEN", 262143},
    {"H4CNF_BS_ENTR", 63},
    {"H4CNF_BS_ABIL", 63},
    {"H4CNF_WEP_DISRP", 3},
    {"H4CNF_ARM_DISRP", 3},
    {"H4CNF_HEL_DISRP", 3},
    {"H4CNF_APPROACH", 0xFFFFFFF}
}

local USER_CAN_MDFY_PRESET_AUTO_RNSOLO = {
    {"",},
    {"H4CNF_BOLTCUT", 4424},
    {"H4CNF_UNIFORM", 5256},
    {"H4CNF_GRAPPEL", 5156},
    {"H4_MISSIONS", 0xFFFFFFF},
    {"H4CNF_WEAPONS", 1},
    {"H4CNF_TROJAN", 5},
    {"H4_PLAYTHROUGH_STATUS", 100}
}
    menu.add_feature("Ruby Necklace", "toggle", AUTOMATED_SOLO.id, function(SOLO_RUBY_var0)
    menu.notify("Preset modified to SOLO\n- Don't use any advanced options\n- Don't use bag modifier\n- Don't change the percentage set by the script\n- Fill the bag\n\n- Leave this option enabled until you finish the Heist", "Cayo Perico SOLO | Ruby Necklace", 7, 0xffcc63a6)
        for i = 1, #USER_CAN_MDFY_PRESET_AUTO_RNSOLO do
        stat_set_int(USER_CAN_MDFY_PRESET_AUTO_RNSOLO[i][1], true, USER_CAN_MDFY_PRESET_AUTO_RNSOLO[i][2])
        end
        while SOLO_RUBY_var0.on do      
        for i = 2, #AUTO_SOLO_RUBY_HARD do
        stat_set_int(AUTO_SOLO_RUBY_HARD[i][1], true, AUTO_SOLO_RUBY_HARD[i][2])
        end      
        script.set_global_f(262145+29470,-0.1) --pavel cut protection
        script.set_global_f(262145+29471,-0.02) --fency fee cut protection
        script.set_global_i(262145+29227,1800) -- bag protection
        script.set_global_i(1711169,100) -- cut original version 1710289 + 823 + 56 + 1
        if not SOLO_RUBY_var0.on then return end
        system.wait(0)
        end
end)
end
----- AUTOMATED 2 PLAYERS
do
local AUTO_2PLAYERs_SAPPHIRE_NORMAL = {
    {"",},
    {"H4CNF_TARGET", 5},
    {"H4LOOT_CASH_I", 2359448},
    {"H4LOOT_CASH_I_SCOPED", 2359448},
    {"H4LOOT_CASH_C", 0},
    {"H4LOOT_CASH_C_SCOPED", 0},
    {"H4LOOT_COKE_I", 2},
    {"H4LOOT_COKE_I_SCOPED", 2},
    {"H4LOOT_COKE_C", 0},
    {"H4LOOT_COKE_C_SCOPED", 0},
    {"H4LOOT_GOLD_I", 0},
    {"H4LOOT_GOLD_I_SCOPED", 0},
    {"H4LOOT_GOLD_C", 255},
    {"H4LOOT_GOLD_C_SCOPED", 255},
    {"H4LOOT_WEED_I", 0},
    {"H4LOOT_WEED_I_SCOPED", 0},
    {"H4LOOT_WEED_C", 0},
    {"H4LOOT_WEED_C_SCOPED", 0},
    {"H4LOOT_PAINT", 127},
    {"H4LOOT_PAINT_SCOPED", 127},
    {"H4LOOT_CASH_V", 474431},
    {"H4LOOT_COKE_V", 948863},
    {"H4LOOT_GOLD_V", 1265151},
    {"H4LOOT_PAINT_V", 948863},
    {"H4LOOT_WEED_V", 0},
        --
    {"H4_PROGRESS", 126823},
    {"H4CNF_BS_GEN", 262143},
    {"H4CNF_BS_ENTR", 63},
    {"H4CNF_BS_ABIL", 63},
    {"H4CNF_WEP_DISRP", 3},
    {"H4CNF_ARM_DISRP", 3},
    {"H4CNF_HEL_DISRP", 3},
    {"H4CNF_APPROACH", 0xFFFFFFF}
}
local USER_CAN_MDFY_PRESET_AUTO_SPDUO = {
    {"",},
    {"H4CNF_BOLTCUT", 4424},
    {"H4CNF_UNIFORM", 5256},
    {"H4CNF_GRAPPEL", 5156},
    {"H4_MISSIONS", 0xFFFFFFF},
    {"H4CNF_WEAPONS", 1},
    {"H4CNF_TROJAN", 5},
    {"H4_PLAYTHROUGH_STATUS", 100}
}
menu.add_feature("Sapphire Panther", "toggle", AUTOMATED_2P.id, function(AUTO_2_SAPH_var0)
    ui.notify_above_map("~h~Heist Control has blocked changes to player percentages.\n\n~g~To each player 25%", "", 96)
    ui.notify_above_map("~h~Estimated payout for each player\n~g~$2,550,000", "", 96)
    menu.notify("Preset added for 2 players\n- Don't use any advanced options\n- Don't use bag modifier\n- Don't change the percentage set by the script\n- Fill the bag\n\n- Leave this option enabled until you finish the Heist", "Cayo Perico 2 Players | Sapphire Panther", 7, 0xffcc63a6)
    for i = 1, #USER_CAN_MDFY_PRESET_AUTO_SPDUO do
    stat_set_int(USER_CAN_MDFY_PRESET_AUTO_SPDUO[i][1], true, USER_CAN_MDFY_PRESET_AUTO_SPDUO[i][2])
    end
    while AUTO_2_SAPH_var0.on do
    for i = 1, #AUTO_2PLAYERs_SAPPHIRE_NORMAL do
    stat_set_int(AUTO_2PLAYERs_SAPPHIRE_NORMAL[i][1], true, AUTO_2PLAYERs_SAPPHIRE_NORMAL[i][2])
    end
    script.set_global_f(262145+29470,-0.1) --pavel cut protection
    script.set_global_f(262145+29471,-0.02) --fency fee cut protection
    script.set_global_i(262145+29227,1800) -- bag protection
    script.set_global_i(1711169,50)
    script.set_global_i(1711170,50)
    if not AUTO_2_SAPH_var0.on then return end
    system.wait(0)
end
end)
end

--- AUTOMATED 2 RUBY
do
local AUTO_2PLAYERs_RUBY_NORMAL = {
    {"",},
    {"H4CNF_TARGET", 1},
    {"H4LOOT_CASH_I", 9208137},
    {"H4LOOT_CASH_I_SCOPED", 9208137},
    {"H4LOOT_CASH_C", 0},
    {"H4LOOT_CASH_C_SCOPED", 0},
    {"H4LOOT_COKE_I", 1048704},
    {"H4LOOT_COKE_I_SCOPED", 1048704},
    {"H4LOOT_COKE_C", 0},
    {"H4LOOT_COKE_C_SCOPED", 0},
    {"H4LOOT_GOLD_I", 0},
    {"H4LOOT_GOLD_I_SCOPED", 0},
    {"H4LOOT_GOLD_C", 255},
    {"H4LOOT_GOLD_C_SCOPED", 255},
    {"H4LOOT_WEED_I", 4206596},
    {"H4LOOT_WEED_I_SCOPED", 4206596},
    {"H4LOOT_WEED_C", 0},
    {"H4LOOT_WEED_C_SCOPED", 0},
    {"H4LOOT_PAINT", 127},
    {"H4LOOT_PAINT_SCOPED", 127},
    {"H4LOOT_CASH_V", 572727},
    {"H4LOOT_COKE_V", 1145454},
    {"H4LOOT_GOLD_V", 1527272},
    {"H4LOOT_PAINT_V", 1145454},
    {"H4LOOT_WEED_V", 916363},
    --
    {"H4_PROGRESS", 126823},
    {"H4CNF_BS_GEN", 262143},
    {"H4CNF_BS_ENTR", 63},
    {"H4CNF_BS_ABIL", 63},
    {"H4CNF_WEP_DISRP", 3},
    {"H4CNF_ARM_DISRP", 3},
    {"H4CNF_HEL_DISRP", 3},
    {"H4CNF_APPROACH", 0xFFFFFFF}
}
local USER_CAN_MDFY_PRESET_AUTO_RBDUO = {
    {"",},
    {"H4CNF_BOLTCUT", 4424},
    {"H4CNF_UNIFORM", 5256},
    {"H4CNF_GRAPPEL", 5156},
    {"H4_MISSIONS", 0xFFFFFFF},
    {"H4CNF_WEAPONS", 1},
    {"H4CNF_TROJAN", 5},
    {"H4_PLAYTHROUGH_STATUS", 100}
}
    menu.add_feature("Ruby Necklace", "toggle", AUTOMATED_2P.id, function(AUTO_2_RUBY_var0)
    menu.notify("Preset added for 2 players\n- Don't use any advanced options\n- Don't use bag modifier\n- Don't change the percentage set by the script\n- Fill the bag\n\n- Leave this option enabled until you finish the Heist", "Cayo Perico 2 Players | Ruby Necklace", 7, 0xffcc63a6)
    ui.notify_above_map("~h~Heist Control has blocked changes to player percentages.\n\n~g~To each player 50%", "", 96)
    ui.notify_above_map("~h~Estimated payout for each player\n~g~$2,550,000", "", 96)
    for i = 1, #USER_CAN_MDFY_PRESET_AUTO_RBDUO do
    stat_set_int(USER_CAN_MDFY_PRESET_AUTO_RBDUO[i][1], true, USER_CAN_MDFY_PRESET_AUTO_RBDUO[i][2])
    end
    while AUTO_2_RUBY_var0.on do
    for i = 1, #AUTO_2PLAYERs_RUBY_NORMAL do
    stat_set_int(AUTO_2PLAYERs_RUBY_NORMAL[i][1], true, AUTO_2PLAYERs_RUBY_NORMAL[i][2])
    script.set_global_f(262145+29470,-0.1) --pavel cut protection
    script.set_global_f(262145+29471,-0.02) --fency fee cut protection
    script.set_global_i(262145+29227,1800) -- bag protection
    script.set_global_i(1711169,50)
    script.set_global_i(1711170,50)
    if not AUTO_2_RUBY_var0.on then return end
    system.wait(0)
    end
end
end)
end

do
--- CAYO AUTOMATED PRESET 3 PLAYERS
local AUTO_3PLAYERs_SAPPHIRE_NORMAL = {
    {"",},
    {"H4CNF_TARGET", 5},
    {"H4LOOT_CASH_I", 2359448},
    {"H4LOOT_CASH_I_SCOPED", 2359448},
    {"H4LOOT_CASH_C", 0},
    {"H4LOOT_CASH_C_SCOPED", 0},
    {"H4LOOT_COKE_I", 4901222},
    {"H4LOOT_COKE_I_SCOPED", 4901222},
    {"H4LOOT_COKE_C", 0},
    {"H4LOOT_COKE_C_SCOPED", 0},
    {"H4LOOT_GOLD_I", 0},
    {"H4LOOT_GOLD_I_SCOPED", 0},
    {"H4LOOT_GOLD_C", 255},
    {"H4LOOT_GOLD_C_SCOPED", 255},
    {"H4LOOT_WEED_I", 0},
    {"H4LOOT_WEED_I_SCOPED", 0},
    {"H4LOOT_WEED_C", 0},
    {"H4LOOT_WEED_C_SCOPED", 0},
    {"H4LOOT_PAINT", 127},
    {"H4LOOT_PAINT_SCOPED", 127},
    {"H4LOOT_CASH_V", 515151},
    {"H4LOOT_COKE_V", 1030303},
    {"H4LOOT_GOLD_V", 1373737},
    {"H4LOOT_PAINT_V", 1030303},
    {"H4LOOT_WEED_V", 0},
    --
    {"H4_PROGRESS", 126823},
    {"H4CNF_BS_GEN", 262143},
    {"H4CNF_BS_ENTR", 63},
    {"H4CNF_BS_ABIL", 63},
    {"H4CNF_WEP_DISRP", 3},
    {"H4CNF_ARM_DISRP", 3},
    {"H4CNF_HEL_DISRP", 3},
    {"H4CNF_APPROACH", 0xFFFFFFF}
}
local USER_CAN_MDFY_PRESET_AUTO_SPTRIO = {
    {"",},
    {"H4CNF_BOLTCUT", 4424},
    {"H4CNF_UNIFORM", 5256},
    {"H4CNF_GRAPPEL", 5156},
    {"H4_MISSIONS", 0xFFFFFFF},
    {"H4CNF_WEAPONS", 1},
    {"H4CNF_TROJAN", 5},
    {"H4_PLAYTHROUGH_STATUS", 100}
}
    menu.add_feature("Sapphire Panther", "toggle", AUTOMATED_3P.id, function(AUTO_3_SAPH_var0)
    menu.notify("Preset added for 3 players\n- Don't use any advanced options\n- Don't use bag modifier\n- Don't change the percentage set by the script\n- Fill the bag\n\n- Leave this option enabled until you finish the Heist", "Cayo Perico 3 Players | Sapphire Panther", 7, 0xffcc63a6)
    ui.notify_above_map("~h~Heist Control has blocked changes to player percentages.\n\n~g~Host 30%\nOthers players 35%", "", 96)
    ui.notify_above_map("~h~Estimated payout for each player\n~g~$2,550,000", "", 96)
    for i = 1, #USER_CAN_MDFY_PRESET_AUTO_SPTRIO do
    stat_set_int(USER_CAN_MDFY_PRESET_AUTO_SPTRIO[i][1], true, USER_CAN_MDFY_PRESET_AUTO_SPTRIO[i][2])
    end
        while AUTO_3_SAPH_var0.on do    
        for i = 1, #AUTO_3PLAYERs_SAPPHIRE_NORMAL do
        stat_set_int(AUTO_3PLAYERs_SAPPHIRE_NORMAL[i][1], true, AUTO_3PLAYERs_SAPPHIRE_NORMAL[i][2])
        script.set_global_f(262145+29470,-0.1) --pavel cut protection
        script.set_global_f(262145+29471,-0.02) --fency fee cut protection
        script.set_global_i(262145+29227,1800) -- bag protection
        script.set_global_i(1711169,30)
        script.set_global_i(1711170,35)
        script.set_global_i(1711171,35)
        if not AUTO_3_SAPH_var0.on then return end
        system.wait(0)
    end
    end
end)
end

do
--- CAYO AUTOMATED 3 PLAYERS RUBY
local AUTO_3PLAYERs_RUBY_NORMAL = {
    {"",},
    {"H4CNF_TARGET", 1},
    {"H4LOOT_CASH_I", 9208137},
    {"H4LOOT_CASH_I_SCOPED", 9208137},
    {"H4LOOT_CASH_C", 0},
    {"H4LOOT_CASH_C_SCOPED", 0},
    {"H4LOOT_COKE_I", 1048704},
    {"H4LOOT_COKE_I_SCOPED", 1048704},
    {"H4LOOT_COKE_C", 0},
    {"H4LOOT_COKE_C_SCOPED", 0},
    {"H4LOOT_GOLD_I", 0},
    {"H4LOOT_GOLD_I_SCOPED", 0},
    {"H4LOOT_GOLD_C", 255},
    {"H4LOOT_GOLD_C_SCOPED", 255},
    {"H4LOOT_WEED_I", 4206596},
    {"H4LOOT_WEED_I_SCOPED", 4206596},
    {"H4LOOT_WEED_C", 0},
    {"H4LOOT_WEED_C_SCOPED", 0},
    {"H4LOOT_PAINT", 127},
    {"H4LOOT_PAINT_SCOPED", 127},
    {"H4LOOT_CASH_V", 598268},
    {"H4LOOT_COKE_V", 1196536},
    {"H4LOOT_GOLD_V", 1595382},
    {"H4LOOT_PAINT_V", 1196536},
    {"H4LOOT_WEED_V", 957229},
    --
    {"H4_PROGRESS", 126823},
    {"H4CNF_BS_GEN", 262143},
    {"H4CNF_BS_ENTR", 63},
    {"H4CNF_BS_ABIL", 63},
    {"H4CNF_WEP_DISRP", 3},
    {"H4CNF_ARM_DISRP", 3},
    {"H4CNF_HEL_DISRP", 3},
    {"H4CNF_APPROACH", 0xFFFFFFF}
}
local USER_CAN_MDFY_PRESET_AUTO_RBTRIO = {
    {"",},
    {"H4CNF_BOLTCUT", 4424},
    {"H4CNF_UNIFORM", 5256},
    {"H4CNF_GRAPPEL", 5156},
    {"H4_MISSIONS", 0xFFFFFFF},
    {"H4CNF_WEAPONS", 1},
    {"H4CNF_TROJAN", 5},
    {"H4_PLAYTHROUGH_STATUS", 100}
}
    menu.add_feature("Ruby Necklace", "toggle", AUTOMATED_3P.id, function(AUTO_3_RUBY_var0)
    menu.notify("Preset added for 3 players\n- Don't use any advanced options\n- Don't use bag modifier\n- Don't change the percentage set by the script\n- Fill the bag\n\n- Leave this option enabled until you finish the Heist", "Cayo Perico 3 Players | Ruby Necklace", 7, 0xffcc63a6)
    ui.notify_above_map("~h~Heist Control has blocked changes to player percentages.\n\n~g~Host 30%\nOthers players 35%", "", 96)
    ui.notify_above_map("~h~Estimated payout for each player\n~g~$2,550,000", "", 96)
    for i = 1, #USER_CAN_MDFY_PRESET_AUTO_RBTRIO do
        stat_set_int(USER_CAN_MDFY_PRESET_AUTO_RBTRIO[i][1], true, USER_CAN_MDFY_PRESET_AUTO_RBTRIO[i][2])
    end
    while AUTO_3_RUBY_var0.on do
        for i = 1, #AUTO_3PLAYERs_RUBY_NORMAL do
        stat_set_int(AUTO_3PLAYERs_RUBY_NORMAL[i][1], true, AUTO_3PLAYERs_RUBY_NORMAL[i][2])
        script.set_global_f(262145+29470,-0.1) --pavel cut protection
        script.set_global_f(262145+29471,-0.02) --fency fee cut protection
        script.set_global_i(262145+29227,1800) -- bag protection
        script.set_global_i(1711169,30)
        script.set_global_i(1711170,35)
        script.set_global_i(1711171,35)
        if not AUTO_3_RUBY_var0.on then return end
        system.wait(0)
    end
    end
end)
end

--- CAYO AUTOMATED PRESET 4 PLAYERS
do
local AUTO_4PLAYERs_SAPPHIRE_NORMAL = {
    {"",},
    {"H4CNF_TARGET", 5},
    {"H4LOOT_CASH_I", 2359448},
    {"H4LOOT_CASH_I_SCOPED", 2359448},
    {"H4LOOT_CASH_C", 0},
    {"H4LOOT_CASH_C_SCOPED", 0},
    {"H4LOOT_COKE_I", 4901222},
    {"H4LOOT_COKE_I_SCOPED", 4901222},
    {"H4LOOT_COKE_C", 0},
    {"H4LOOT_COKE_C_SCOPED", 0},
    {"H4LOOT_GOLD_I", 0},
    {"H4LOOT_GOLD_I_SCOPED", 0},
    {"H4LOOT_GOLD_C", 255},
    {"H4LOOT_GOLD_C_SCOPED", 255},
    {"H4LOOT_WEED_I", 0},
    {"H4LOOT_WEED_I_SCOPED", 0},
    {"H4LOOT_WEED_C", 0},
    {"H4LOOT_WEED_C_SCOPED", 0},
    {"H4LOOT_PAINT", 127},
    {"H4LOOT_PAINT_SCOPED", 127},
    {"H4LOOT_CASH_V", 599431},
    {"H4LOOT_COKE_V", 1198863},
    {"H4LOOT_GOLD_V", 1598484},
    {"H4LOOT_PAINT_V", 1198863},
    {"H4LOOT_WEED_V", 0},
        --
    {"H4_PROGRESS", 126823},
    {"H4CNF_BS_GEN", 262143},
    {"H4CNF_BS_ENTR", 63},
    {"H4CNF_BS_ABIL", 63},
    {"H4CNF_WEP_DISRP", 3},
    {"H4CNF_ARM_DISRP", 3},
    {"H4CNF_HEL_DISRP", 3},
    {"H4CNF_APPROACH", 0xFFFFFFF}
}
local USER_CAN_MDFY_PRESET_AUTO_SPQUAD = {
    {"",},
    {"H4CNF_BOLTCUT", 4424},
    {"H4CNF_UNIFORM", 5256},
    {"H4CNF_GRAPPEL", 5156},
    {"H4_MISSIONS", 0xFFFFFFF},
    {"H4CNF_WEAPONS", 1},
    {"H4CNF_TROJAN", 5},
    {"H4_PLAYTHROUGH_STATUS", 100}
}
menu.add_feature("Sapphire Panther", "toggle", AUTOMATED_4P.id, function(AUTO_4_SAPH_var0)
    menu.notify("Preset added for 4 players\n- Don't use any advanced options\n- Don't use bag modifier\n- Don't change the percentage set by the script\n- Fill the bag\n\n- Leave this option enabled until you finish the Heist", "Cayo Perico 4 Players | Sapphire Panther", 7, 0xffcc63a6)
    ui.notify_above_map("~h~Heist Control has blocked changes to player percentages.\n\n~g~To each player 25%", "", 96)
    ui.notify_above_map("~h~Estimated payout for each player\n~g~$2,550,000", "", 96)
    for i = 1, #USER_CAN_MDFY_PRESET_AUTO_SPQUAD do
        stat_set_int(USER_CAN_MDFY_PRESET_AUTO_SPQUAD[i][1], true, USER_CAN_MDFY_PRESET_AUTO_SPQUAD[i][2])
    end
        while AUTO_4_SAPH_var0.on do
        for i = 1, #AUTO_4PLAYERs_SAPPHIRE_NORMAL do
        stat_set_int(AUTO_4PLAYERs_SAPPHIRE_NORMAL[i][1], true, AUTO_4PLAYERs_SAPPHIRE_NORMAL[i][2])
        script.set_global_f(262145+29470,-0.1) --pavel cut protection
        script.set_global_f(262145+29471,-0.02) --fency fee cut protection
        script.set_global_i(262145+29227,1800) -- bag protection
        script.set_global_i(1711169,25) -- player 1
        script.set_global_i(1711170,25) -- player 2
        script.set_global_i(1711171,25) -- player 3
        script.set_global_i(1711172,25) -- player 4
        if not AUTO_4_SAPH_var0.on then return end
         system.wait(0)
    end
    end
end)
end

--- CAYO AUTOMATED PRESET 4 PLAYERS RUBY
do
local AUTO_4PLAYERs_RUBY_NORMAL = {
    {"",},
    {"H4CNF_TARGET", 1},
    {"H4LOOT_CASH_I", 9208137},
    {"H4LOOT_CASH_I_SCOPED", 9208137},
    {"H4LOOT_CASH_C", 0},
    {"H4LOOT_CASH_C_SCOPED", 0},
    {"H4LOOT_COKE_I", 1048704},
    {"H4LOOT_COKE_I_SCOPED", 1048704},
    {"H4LOOT_COKE_C", 0},
    {"H4LOOT_COKE_C_SCOPED", 0},
    {"H4LOOT_GOLD_I", 0},
    {"H4LOOT_GOLD_I_SCOPED", 0},
    {"H4LOOT_GOLD_C", 255},
    {"H4LOOT_GOLD_C_SCOPED", 255},
    {"H4LOOT_WEED_I", 4206596},
    {"H4LOOT_WEED_I_SCOPED", 4206596},
    {"H4LOOT_WEED_C", 0},
    {"H4LOOT_WEED_C_SCOPED", 0},
    {"H4LOOT_PAINT", 127},
    {"H4LOOT_PAINT_SCOPED", 127},
    {"H4LOOT_CASH_V", 655681},
    {"H4LOOT_COKE_V", 1311363},
    {"H4LOOT_GOLD_V", 1748484},
    {"H4LOOT_PAINT_V", 1311363},
    {"H4LOOT_WEED_V", 1049090},
     --
    {"H4_PROGRESS", 126823},
    {"H4CNF_BS_GEN", 262143},
    {"H4CNF_BS_ENTR", 63},
    {"H4CNF_BS_ABIL", 63},
    {"H4CNF_WEP_DISRP", 3},
    {"H4CNF_ARM_DISRP", 3},
    {"H4CNF_HEL_DISRP", 3},
    {"H4CNF_APPROACH", 0xFFFFFFF}
}
local USER_CAN_MDFY_PRESET_AUTO_RBQUAD = {
    {"",},
    {"H4CNF_BOLTCUT", 4424},
    {"H4CNF_UNIFORM", 5256},
    {"H4CNF_GRAPPEL", 5156},
    {"H4_MISSIONS", 0xFFFFFFF},
    {"H4CNF_WEAPONS", 1},
    {"H4CNF_TROJAN", 5},
    {"H4_PLAYTHROUGH_STATUS", 100}
}
    menu.add_feature("Ruby Necklace", "toggle", AUTOMATED_4P.id, function(AUTO_4_RUBY_var0)
    menu.notify("Preset added for 4 players\n- Don't use any advanced options\n- Don't use bag modifier\n- Don't change the percentage set by the script\n- Fill the bag\n\n- Leave this option enabled until you finish the Heist", "Cayo Perico 4 Players | Ruby Necklace", 7, 0xffcc63a6)
    ui.notify_above_map("~h~Heist Control has blocked changes to player percentages.\n\n~g~To each player 25%", "", 96)
    ui.notify_above_map("~h~Estimated payout for each player\n~g~$2,550,000", "", 96)
    for i = 1, #USER_CAN_MDFY_PRESET_AUTO_RBQUAD do
        stat_set_int(USER_CAN_MDFY_PRESET_AUTO_RBQUAD[i][1], true, USER_CAN_MDFY_PRESET_AUTO_RBQUAD[i][2])
    end
    while AUTO_4_RUBY_var0.on do    
        for i = 1, #AUTO_4PLAYERs_RUBY_NORMAL do
        stat_set_int(AUTO_4PLAYERs_RUBY_NORMAL[i][1], true, AUTO_4PLAYERs_RUBY_NORMAL[i][2])
        script.set_global_f(262145+29470,-0.1) --pavel cut protection
        script.set_global_f(262145+29471,-0.02) --fency fee cut protection
        script.set_global_i(262145+29227,1800) -- bag protection
        script.set_global_i(1711169,25) -- player 1
        script.set_global_i(1711170,25) -- player 2
        script.set_global_i(1711171,25) -- player 3
        script.set_global_i(1711172,25) -- player 4
        if not AUTO_4_RUBY_var0.on then return end
        system.wait(0)
    end
end
end)
end

-- WEEKLY EVENT (PRESETS)
-- SOLO ONE
do
local WKLY_SOLO_PANTHER = {
    {"",},
    {"H4CNF_TARGET", 5},
    {"H4LOOT_CASH_I", 6490148},
    {"H4LOOT_CASH_I_SCOPED", 6490148},
    {"H4LOOT_CASH_C", 0},
    {"H4LOOT_CASH_C_SCOPED", 0},
    {"H4LOOT_COKE_I", 8421904},
    {"H4LOOT_COKE_I_SCOPED", 8421904},
    {"H4LOOT_COKE_C", 0},
    {"H4LOOT_COKE_C_SCOPED", 0},
    {"H4LOOT_GOLD_I", 0},
    {"H4LOOT_GOLD_I_SCOPED", 0},
    {"H4LOOT_GOLD_C", 255},
    {"H4LOOT_GOLD_C_SCOPED", 255},
    {"H4LOOT_WEED_I", 1311112},
    {"H4LOOT_WEED_I_SCOPED", 1311112},
    {"H4LOOT_WEED_C", 0},
    {"H4LOOT_WEED_C_SCOPED", 0},
    {"H4LOOT_PAINT", 127},
    {"H4LOOT_PAINT_SCOPED", 127},
    {"H4LOOT_CASH_V", 670454},
    {"H4LOOT_COKE_V", 1340909},
    {"H4LOOT_GOLD_V", 1787878},
    {"H4LOOT_PAINT_V", 1340909},
    {"H4LOOT_WEED_V", 1072727},
         --
    {"H4_PROGRESS", 126823},
    {"H4CNF_BS_GEN", 262143},
    {"H4CNF_BS_ENTR", 63},
    {"H4CNF_BS_ABIL", 63},
    {"H4CNF_WEP_DISRP", 3},
    {"H4CNF_ARM_DISRP", 3},
    {"H4CNF_HEL_DISRP", 3},
    {"H4CNF_APPROACH", 0xFFFFFFF}
}

local USER_CAN_MDFY_WKLY_SOLO_PANTHER= {
    {"",},
    {"H4CNF_BOLTCUT", 4424},
    {"H4CNF_UNIFORM", 5256},
    {"H4CNF_GRAPPEL", 5156},
    {"H4_MISSIONS", 0xFFFFFFF},
    {"H4CNF_WEAPONS", 1},
    {"H4CNF_TROJAN", 5},
    {"H4_PLAYTHROUGH_STATUS", 100}
}
    menu.add_feature("Sapphire Panther", "toggle", WEEKLY_SOLO.id, function(WEEKLY_SOLO_v0)
    menu.notify("Preset added to SOLO\n- Don't use any advanced options\n- Don't use bag modifier\n- Don't change the percentage set by the script\n- Fill your bag with ANY item (Just fill it out)\n\n- Leave this option enabled until you finish the Heist", "Cayo Perico SOLO | Sapphire Panther", 7, 0x6414F0FF)
    ui.notify_above_map("~h~Estimated payout for you\n~g~$4,100,000 ~s~[~r~Weekly Event~s~]", "", 96)
    for i = 1, #USER_CAN_MDFY_WKLY_SOLO_PANTHER do
        stat_set_int(USER_CAN_MDFY_WKLY_SOLO_PANTHER[i][1], true, USER_CAN_MDFY_WKLY_SOLO_PANTHER[i][2])
    end
    while WEEKLY_SOLO_v0.on do
        for i = 1, #WKLY_SOLO_PANTHER do
        stat_set_int(WKLY_SOLO_PANTHER[i][1], true, WKLY_SOLO_PANTHER[i][2])
        script.set_global_f(262145+29470,-0.1) -- Pavel cut protection
        script.set_global_f(262145+29471,-0.02) --Fency fee cut protection
        script.set_global_i(262145+29227,1800) -- Bag protection
        script.set_global_i(1711169,100) -- Player 1 (SOLO)
        if not WEEKLY_SOLO_v0.on then return end
        system.wait(0)
    end
end
end)
end

-- WEEKLY DUO
do
local WKLY_DUO_PANTHER = {
    {"",},
    {"H4CNF_TARGET", 5},
    {"H4LOOT_CASH_I", 6490148},
    {"H4LOOT_CASH_I_SCOPED", 6490148},
    {"H4LOOT_CASH_C", 0},
    {"H4LOOT_CASH_C_SCOPED", 0},
    {"H4LOOT_COKE_I", 8421904},
    {"H4LOOT_COKE_I_SCOPED", 8421904},
    {"H4LOOT_COKE_C", 0},
    {"H4LOOT_COKE_C_SCOPED", 0},
    {"H4LOOT_GOLD_I", 0},
    {"H4LOOT_GOLD_I_SCOPED", 0},
    {"H4LOOT_GOLD_C", 255},
    {"H4LOOT_GOLD_C_SCOPED", 255},
    {"H4LOOT_WEED_I", 1311112},
    {"H4LOOT_WEED_I_SCOPED", 1311112},
    {"H4LOOT_WEED_C", 0},
    {"H4LOOT_WEED_C_SCOPED", 0},
    {"H4LOOT_PAINT", 127},
    {"H4LOOT_PAINT_SCOPED", 127},
    {"H4LOOT_CASH_V", 920454},
    {"H4LOOT_COKE_V", 1840909},
    {"H4LOOT_GOLD_V", 2454545},
    {"H4LOOT_PAINT_V", 1840909},
    {"H4LOOT_WEED_V", 1472727},
            --
    {"H4_PROGRESS", 126823},
    {"H4CNF_BS_GEN", 262143},
    {"H4CNF_BS_ENTR", 63},
    {"H4CNF_BS_ABIL", 63},
    {"H4CNF_WEP_DISRP", 3},
    {"H4CNF_ARM_DISRP", 3},
    {"H4CNF_HEL_DISRP", 3},
    {"H4CNF_APPROACH", 0xFFFFFFF}
}
local USER_CAN_MDFY_WKLY_DUO_PANTHER = {
    {"",},
    {"H4CNF_BOLTCUT", 4424},
    {"H4CNF_UNIFORM", 5256},
    {"H4CNF_GRAPPEL", 5156},
    {"H4_MISSIONS", 0xFFFFFFF},
    {"H4CNF_WEAPONS", 1},
    {"H4CNF_TROJAN", 5},
    {"H4_PLAYTHROUGH_STATUS", 100}
}
menu.add_feature("Sapphire Panther", "toggle", WEEKLY_F2.id, function(WEEKLY_DUO_v0)
menu.notify("Preset added for 2 players\n- Don't use any advanced options\n- Don't use bag modifier\n- Don't change the percentage set by the script\n- Fill your bag with ANY item (Just fill it out)\n\n- Leave this option enabled until you finish the Heist", "Cayo Perico 2 Players | Sapphire Panther", 7, 0x6414F0FF)
ui.notify_above_map("~h~Heist Control has blocked changes to player percentages.\n\n~g~To each player 50%", "", 96)
ui.notify_above_map("~h~Estimated payout for each player\n~g~$4,100,000 ~s~[~r~Weekly Event~s~]", "", 96)
    for i = 1, #USER_CAN_MDFY_WKLY_DUO_PANTHER do
    stat_set_int(USER_CAN_MDFY_WKLY_DUO_PANTHER[i][1], true, USER_CAN_MDFY_WKLY_DUO_PANTHER[i][2])
    end
    while WEEKLY_DUO_v0.on do
    for i = 1, #WKLY_DUO_PANTHER do
    stat_set_int(WKLY_DUO_PANTHER[i][1], true, WKLY_DUO_PANTHER[i][2])
    end
    script.set_global_f(262145+29470,-0.1) --pavel cut protection
    script.set_global_f(262145+29471,-0.02) --fency fee cut protection
    script.set_global_i(262145+29227,1800) -- bag protection
    script.set_global_i(1711169,50)
    script.set_global_i(1711170,50)
    if not WEEKLY_DUO_v0.on then return end
    system.wait(0)
end
end)
end

-- WEEKLY TRIO
do
local WKLY_TRIO_PANTHER = {
    {"",},
    {"H4CNF_TARGET", 5},
    {"H4LOOT_CASH_I", 6490148},
    {"H4LOOT_CASH_I_SCOPED", 6490148},
    {"H4LOOT_CASH_C", 0},
    {"H4LOOT_CASH_C_SCOPED", 0},
    {"H4LOOT_COKE_I", 8421904},
    {"H4LOOT_COKE_I_SCOPED", 8421904},
    {"H4LOOT_COKE_C", 0},
    {"H4LOOT_COKE_C_SCOPED", 0},
    {"H4LOOT_GOLD_I", 0},
    {"H4LOOT_GOLD_I_SCOPED", 0},
    {"H4LOOT_GOLD_C", 255},
    {"H4LOOT_GOLD_C_SCOPED", 255},
    {"H4LOOT_WEED_I", 1311112},
    {"H4LOOT_WEED_I_SCOPED", 1311112},
    {"H4LOOT_WEED_C", 0},
    {"H4LOOT_WEED_C_SCOPED", 0},
    {"H4LOOT_PAINT", 127},
    {"H4LOOT_PAINT_SCOPED", 127},
    {"H4LOOT_CASH_V", 948051},
    {"H4LOOT_COKE_V", 1896103},
    {"H4LOOT_GOLD_V", 2528137},
    {"H4LOOT_PAINT_V", 1896103},
    {"H4LOOT_WEED_V", 1516882},
    --
    {"H4_PROGRESS", 126823},
    {"H4CNF_BS_GEN", 262143},
    {"H4CNF_BS_ENTR", 63},
    {"H4CNF_BS_ABIL", 63},
    {"H4CNF_WEP_DISRP", 3},
    {"H4CNF_ARM_DISRP", 3},
    {"H4CNF_HEL_DISRP", 3},
    {"H4CNF_APPROACH", 0xFFFFFFF}
}
local USER_CAN_MDFY_WKLY_TRIO_PANTHER = {
    {"",},
    {"H4CNF_BOLTCUT", 4424},
    {"H4CNF_UNIFORM", 5256},
    {"H4CNF_GRAPPEL", 5156},
    {"H4_MISSIONS", 0xFFFFFFF},
    {"H4CNF_WEAPONS", 1},
    {"H4CNF_TROJAN", 5},
    {"H4_PLAYTHROUGH_STATUS", 100}
}
    menu.add_feature("Sapphire Panther", "toggle", WEEKLY_F3.id, function(WEEKLY_TRIO_v0)
    menu.notify("Preset added for 3 players\n- Don't use any advanced options\n- Don't use bag modifier\n- Don't change the percentage set by the script\n- Fill your bag with ANY item (Just fill it out)\n\n- Leave this option enabled until you finish the Heist", "Cayo Perico 3 Players | Sapphire Panther", 7, 0x6414F0FF)
    ui.notify_above_map("~h~Heist Control has blocked changes to player percentages.\n\n~g~You: 30%\nOthers: 35%", "", 96)
    ui.notify_above_map("~h~Estimated payout for each player\n~g~$4,100,000 ~s~[~r~Weekly Event~s~]", "", 96)
    for i = 1, #USER_CAN_MDFY_WKLY_TRIO_PANTHER do
    stat_set_int(USER_CAN_MDFY_WKLY_TRIO_PANTHER[i][1], true, USER_CAN_MDFY_WKLY_TRIO_PANTHER[i][2])
    end
        while WEEKLY_TRIO_v0.on do
        for i = 1, #WKLY_TRIO_PANTHER do
        stat_set_int(WKLY_TRIO_PANTHER[i][1], true, WKLY_TRIO_PANTHER[i][2])
        script.set_global_f(262145+29470,-0.1) --pavel cut protection
        script.set_global_f(262145+29471,-0.02) --fency fee cut protection
        script.set_global_i(262145+29227,1800) -- bag protection
        script.set_global_i(1711169,30)
        script.set_global_i(1711170,35)
        script.set_global_i(1711171,35)
        if not WEEKLY_TRIO_v0.on then return end
        system.wait(0)
    end
    end
end)
end

-- WEEKLY FOUR PLAYERS
do
local WKLY_FOUR_PANTHER = {
    {"",},
    {"H4CNF_TARGET", 5},
    {"H4LOOT_CASH_I", 6490148},
    {"H4LOOT_CASH_I_SCOPED", 6490148},
    {"H4LOOT_CASH_C", 0},
    {"H4LOOT_CASH_C_SCOPED", 0},
    {"H4LOOT_COKE_I", 8421904},
    {"H4LOOT_COKE_I_SCOPED", 8421904},
    {"H4LOOT_COKE_C", 0},
    {"H4LOOT_COKE_C_SCOPED", 0},
    {"H4LOOT_GOLD_I", 0},
    {"H4LOOT_GOLD_I_SCOPED", 0},
    {"H4LOOT_GOLD_C", 255},
    {"H4LOOT_GOLD_C_SCOPED", 255},
    {"H4LOOT_WEED_I", 1311112},
    {"H4LOOT_WEED_I_SCOPED", 1311112},
    {"H4LOOT_WEED_C", 0},
    {"H4LOOT_WEED_C_SCOPED", 0},
    {"H4LOOT_PAINT", 127},
    {"H4LOOT_PAINT_SCOPED", 127},
    {"H4LOOT_CASH_V", 1045454},
    {"H4LOOT_COKE_V", 2090909},
    {"H4LOOT_GOLD_V", 2787878},
    {"H4LOOT_PAINT_V", 2090909},
    {"H4LOOT_WEED_V", 1672727},
    --
    {"H4_PROGRESS", 126823},
    {"H4CNF_BS_GEN", 262143},
    {"H4CNF_BS_ENTR", 63},
    {"H4CNF_BS_ABIL", 63},
    {"H4CNF_WEP_DISRP", 3},
    {"H4CNF_ARM_DISRP", 3},
    {"H4CNF_HEL_DISRP", 3},
    {"H4CNF_APPROACH", 0xFFFFFFF}
}
local USER_CAN_MDFY_WKLY_FOUR_PANTHER = {
    {"",},
    {"H4CNF_BOLTCUT", 4424},
    {"H4CNF_UNIFORM", 5256},
    {"H4CNF_GRAPPEL", 5156},
    {"H4_MISSIONS", 0xFFFFFFF},
    {"H4CNF_WEAPONS", 1},
    {"H4CNF_TROJAN", 5},
    {"H4_PLAYTHROUGH_STATUS", 100}
}
    menu.add_feature("Sapphire Panther", "toggle", WEEKLY_F4.id, function(WEEKLY_FOUR_v0)
    menu.notify("Preset added for 4 players\n- Don't use any advanced options\n- Don't use bag modifier\n- Don't change the percentage set by the script\n- Fill your bag with ANY item (Just fill it out)\n\n- Leave this option enabled until you finish the Heist", "Cayo Perico 4 Players | Sapphire Panther", 7, 0x6414F0FF)
    ui.notify_above_map("~h~Heist Control has blocked changes to player percentages.\n\n~g~25% to everyone", "", 96)
    ui.notify_above_map("~h~Estimated payout for each player\n~g~$4,100,000 ~s~[~r~Weekly Event~s~]", "", 96)
    for i = 1, #USER_CAN_MDFY_WKLY_FOUR_PANTHER do
        stat_set_int(USER_CAN_MDFY_WKLY_FOUR_PANTHER[i][1], true, USER_CAN_MDFY_WKLY_FOUR_PANTHER[i][2])
    end
        while WEEKLY_FOUR_v0.on do
        for i = 1, #WKLY_FOUR_PANTHER do
        stat_set_int(WKLY_FOUR_PANTHER[i][1], true, WKLY_FOUR_PANTHER[i][2])
        script.set_global_f(262145+29470,-0.1) --pavel cut protection
        script.set_global_f(262145+29471,-0.02) --fency fee cut protection
        script.set_global_i(262145+29227,1800) -- bag protection
        script.set_global_i(1711169,25) -- player 1
        script.set_global_i(1711170,25) -- player 2
        script.set_global_i(1711171,25) -- player 3
        script.set_global_i(1711172,25) -- player 4
        if not WEEKLY_FOUR_v0.on then return end
        system.wait(0)
    end
    end
end)
end

---- STANDARD SET
do
local STANDARD_PRSET = {
    {"",},
    {"H4CNF_BS_GEN", 262143},
    {"H4CNF_BS_ENTR", 63},
    {"H4CNF_BS_ABIL", 63},
    {"H4CNF_WEP_DISRP", 3},
    {"H4CNF_ARM_DISRP", 3},
    {"H4CNF_HEL_DISRP", 3},
    {"H4CNF_BOLTCUT", 4424},
    {"H4CNF_UNIFORM", 5256},
    {"H4CNF_GRAPPEL", 5156},
    {"H4CNF_APPROACH", 0xFFFFFFF},
    {"H4LOOT_CASH_I", 1089792},
    {"H4LOOT_CASH_C", 0},
    {"H4LOOT_WEED_I", 9114214},
    {"H4LOOT_WEED_C", 37},
    {"H4LOOT_COKE_I", 6573209},
    {"H4LOOT_COKE_C", 26},
    {"H4LOOT_GOLD_I", 0},
    {"H4LOOT_GOLD_C", 192},
    {"H4LOOT_PAINT", 127},
    {"H4_PROGRESS", 124271},
    {"H4LOOT_CASH_V", 22500},
    {"H4LOOT_COKE_V", 55023},
    {"H4LOOT_GOLD_V", 83046},
    {"H4LOOT_PAINT_V", 47375},
    {"H4LOOT_WEED_V", 36967},
    {"H4LOOT_CASH_I_SCOPED", 1089792},
    {"H4LOOT_CASH_C_SCOPED", 0},
    {"H4LOOT_WEED_I_SCOPED", 9114214},
    {"H4LOOT_WEED_C_SCOPED", 37},
    {"H4LOOT_COKE_I_SCOPED", 6573209},
    {"H4LOOT_COKE_C_SCOPED", 26},
    {"H4LOOT_GOLD_I_SCOPED", 0},
    {"H4LOOT_GOLD_C_SCOPED", 192},
    {"H4LOOT_PAINT_SCOPED", 127},
    {"H4_MISSIONS", 0xFFFFFFF},
    {"H4_PLAYTHROUGH_STATUS", 5}
}
local RANDOM_TARGET = {
    {"H4CNF_TARGET", 1,5,1,5},
    {"H4CNF_WEAPONS", 1,5,1,5}
}
    menu.add_feature("Semi-Original Preset (Not calculated)", "action", STANDARD_SET.id, function()
    menu.notify("The preset has been set, remember to be on the limit!\n\nHere you can use\n- Advanced Options (no exceptions)\n- Modify primary and secondary targets\n\nRemember that you will only receive the money if you do not exceed the limit of $2,500,000 per player", "Heist Control", 15, 0x64F06414)
    for i = 1, #STANDARD_PRSET do
    stat_set_int(STANDARD_PRSET[i][1], true, STANDARD_PRSET[i][2])
    end
    for i = 1, #RANDOM_TARGET do
    stat_set_int(RANDOM_TARGET[i][1], true, math.random(RANDOM_TARGET[i][4], RANDOM_TARGET[i][5]))
    end
end)
end
------- ADVANCED FEATURES CAYO

local my_cut1=menu.add_feature("Your Cut", "autoaction_value_i", HSCUT_CP.id, function(a)
    script.set_global_i(1711169,a.value)
end)
my_cut1.max,my_cut1.min,my_cut1.mod=100000,0,25
-- PLAYER 2 CUT MANAGER

local player2_cut1=menu.add_feature("Player 2", "autoaction_value_i", HSCUT_CP.id, function(a)
    script.set_global_i(1711170,a.value)
end)
player2_cut1.max,player2_cut1.min,player2_cut1.mod=100000,0,25
-- PLAYER 3 CUT MANAGER

local player3_cut1=menu.add_feature("Player 3", "autoaction_value_i", HSCUT_CP.id, function(a)
    script.set_global_i(1711171,a.value)
end)
player3_cut1.max,player3_cut1.min,player3_cut1.mod=100000,0,25
-- PLAYER 4 CUT MANAGER

local player4_cut1=menu.add_feature("Plyaer 4", "autoaction_value_i", HSCUT_CP.id, function(a)
    script.set_global_i(1711172,a.value)
end)
player4_cut1.max,player4_cut1.min,player4_cut1.mod=100000,0,25

menu.add_feature("give everyone 100% cut", "action", HSCUT_CP.id, function()
    script.set_global_i(1711169,100)
    script.set_global_i(1711170,100)
    script.set_global_i(1711171,100)
    script.set_global_i(1711172,100)
end)

menu.add_feature("give everyone 200% cut", "action", HSCUT_CP.id, function()
script.set_global_i(1711169,200)
script.set_global_i(1711170,200)
script.set_global_i(1711171,200)
script.set_global_i(1711172,200)
end)
local my_bag=menu.add_feature("Bag Limit(people)", "action_value_i", PERICO_ADV.id, function(a)
    script.set_global_i(262145+29227,1800*a.value)
end)
my_bag.max,my_bag.min,my_bag.mod=100000,1,1

menu.add_feature("Remove Fencing Fee & Pavel Cut", "toggle", PERICO_ADV.id, function(abc)
    menu.notify("Leave activated until the end of the heist", "Heist Control", 5, 0x64F06414)
    while abc.on do
        script.set_global_f(262145+29470,0)
        script.set_global_f(262145+29471,0)
        if not abc.on then return end
        system.wait(900)
    end
end)

-------------------------
do
local CP_VEH_KA = {
    {"H4_MISSIONS", 65283}
}
    menu.add_feature("Submarine KOSATKA", "action", CAYO_VEHICLES.id, function()
        menu.notify("KOSATKA avaliable", "Heist Control", 3, 0xffef5a09)
        for i = 1, #CP_VEH_KA do
            stat_set_int(CP_VEH_KA[i][1], true, CP_VEH_KA[i][2])
        end
    end)
end

do
local CP_VEH_AT = {
    {"H4_MISSIONS", 65413}
}
    menu.add_feature("Plane ALKONOST", "action", CAYO_VEHICLES.id, function()
    menu.notify("ALKONOST avaliable", "Heist Control", 3, 0xffef5a09)
        for i = 1, #CP_VEH_AT do
            stat_set_int(CP_VEH_AT[i][1], true, CP_VEH_AT[i][2])
        end
    end)
end

do
local CP_VEH_VM = {
    {"H4_MISSIONS", 65289}
}
    menu.add_feature("Plane VELUM", "action", CAYO_VEHICLES.id, function()
    menu.notify("VELUM avaliable", "Heist Control", 3, 0xffef5a09)
        for i = 1, #CP_VEH_VM do
            stat_set_int(CP_VEH_VM[i][1], true, CP_VEH_VM[i][2])
        end
    end)
end

do
local CP_VEH_SA = {
    {"H4_MISSIONS", 65425}
}
    menu.add_feature("Helicopter STEALTH ANNIHILATOR", "action", CAYO_VEHICLES.id, function()
    menu.notify("STEALTH ANNIHILATOR avaliable", "Heist Control", 3, 0xffef5a09)
        for i = 1, #CP_VEH_SA do
            stat_set_int(CP_VEH_SA[i][1], true, CP_VEH_SA[i][2])
        end
    end)
end

do
local CP_VEH_PB = {
    {"H4_MISSIONS", 65313}
}
    menu.add_feature("Boat PATROL BOAT", "action", CAYO_VEHICLES.id, function()
    menu.notify("PATROL BOAT avaliable", "Heist Control", 3, 0xffef5a09)
        for i = 1, #CP_VEH_PB do
            stat_set_int(CP_VEH_PB[i][1], true, CP_VEH_PB[i][2])
        end
    end)
end

do
local CP_VEH_LN = {
    {"H4_MISSIONS", 65345}
}
    menu.add_feature("Boat LONGFIN", "action", CAYO_VEHICLES.id, function()
    menu.notify("LONGFIN avaliable", "Heist Control", 3, 0xffef5a09)
        for i = 1, #CP_VEH_LN do
            stat_set_int(CP_VEH_LN[i][1], true, CP_VEH_LN[i][2])
        end
    end)
end

do
local CP_VEH_ALL = {
    {"H4_MISSIONS", 0xFFFFFFF}
}
    menu.add_feature("Unlock All Vehicles", "action", CAYO_VEHICLES.id, function()
    menu.notify("All Vehicles are avaliable", "Heist Control", 3, 0xffef5a09)
        for i = 1, #CP_VEH_ALL do
            stat_set_int(CP_VEH_ALL[i][1], true, CP_VEH_ALL[i][2])
        end
    end)
end


do
local Target_SapphirePanther = {
    {"H4CNF_TARGET", 5}
}
    menu.add_feature("Change to Sapphire Panther", "action", CAYO_PRIMARY.id, function()
    menu.notify("Primary Target Modified to Sapphire Panther\n\n- $1.900,000 (Normal)\n- $2.090,000 (Hard)", "Heist Control", 3, 0xffef5a09)
        for i = 1, #Target_SapphirePanther do
            stat_set_int(Target_SapphirePanther[i][1], true, Target_SapphirePanther[i][2])
        end
    end)
end

do
local Target_MadrazoF = {
    {"H4CNF_TARGET", 4}
}
    menu.add_feature("Change to Madrazo Files", "action", CAYO_PRIMARY.id, function()
    menu.notify("Primary Target Modified to Madrazo Files\n\n- $1.100,000 (Normal)\n- $1.210,000 (Hard)", "Heist Control", 3, 0xffef5a09)
        for i = 1, #Target_MadrazoF do
            stat_set_int(Target_MadrazoF[i][1], true, Target_MadrazoF[i][2])
        end
    end)
end

do
local Target_PinkDiamond = {
    {"H4CNF_TARGET", 3}
}
    menu.add_feature("Change to Pink Diamond", "action", CAYO_PRIMARY.id, function()
    menu.notify("Primary Target Modified to Pink Diamond\n\n- $1.300,000 (Normal)\n- $1.430,000 (Hard)", "Heist Control", 3, 0xffef5a09)
        for i = 1, #Target_PinkDiamond do
            stat_set_int(Target_PinkDiamond[i][1], true, Target_PinkDiamond[i][2])
        end
    end)
end

do
local Target_BearerBonds = {
    {"H4CNF_TARGET", 2}
}
    menu.add_feature("Change to Bearer Bonds", "action", CAYO_PRIMARY.id, function()
    menu.notify("Primary Target Modified to Bearer Bonds\n\n- $1.100,000 (Normal)\n- $1.210,000 (Hard)", "Heist Control", 3, 0xffef5a09)
        for i = 1, #Target_BearerBonds do
            stat_set_int(Target_BearerBonds[i][1], true, Target_BearerBonds[i][2])
        end
    end)
end

do
local Target_Ruby = {
    {"H4CNF_TARGET", 1}
}
    menu.add_feature("Change to Ruby", "action", CAYO_PRIMARY.id, function()
    menu.notify("Primary Target Modified to Ruby\n\n- $1.000,000 (Normal)\n- $1.100,000 (Hard)", "Heist Control", 3, 0xffef5a09)
    for i = 1, #Target_Ruby do
            stat_set_int(Target_Ruby[i][1], true, Target_Ruby[i][2])
        end
    end)
end

do
local Target_Tequila = {
    {"H4CNF_TARGET", 0}
}
    menu.add_feature("Change to Tequila", "action", CAYO_PRIMARY.id, function()
    menu.notify("Primary Target Modified to Tequila\n\n- $900,000 (Normal)\n- $990,000 (Hard)", "Heist Control", 3, 0xffef5a09)
        for i = 1, #Target_Tequila do
        stat_set_int(Target_Tequila[i][1], true, Target_Tequila[i][2])
        end
    end)
end

do
local SecondaryT_RDM = {
    {"H4LOOT_CASH_I", 1319624},
    {"H4LOOT_CASH_C", 18},
    {"H4LOOT_CASH_V", 89400},
    {"H4LOOT_WEED_I", 2639108},
    {"H4LOOT_WEED_C", 36},
    {"H4LOOT_WEED_V", 149000},
    {"H4LOOT_COKE_I", 4229122},
    {"H4LOOT_COKE_C", 72},
    {"H4LOOT_COKE_V", 221200},
    {"H4LOOT_GOLD_I", 8589313},
    {"H4LOOT_GOLD_C", 129},
    {"H4LOOT_GOLD_V", 322600},
    {"H4LOOT_PAINT", 127},
    {"H4LOOT_PAINT_V", 186800},
    {"H4LOOT_CASH_I_SCOPED", 1319624},
    {"H4LOOT_CASH_C_SCOPED", 18},
    {"H4LOOT_WEED_I_SCOPED", 2639108},
    {"H4LOOT_WEED_C_SCOPED", 36},    
    {"H4LOOT_COKE_I_SCOPED", 4229122},
    {"H4LOOT_COKE_C_SCOPED", 72},
    {"H4LOOT_GOLD_I_SCOPED", 8589313},
    {"H4LOOT_GOLD_C_SCOPED", 129},
    {"H4LOOT_PAINT_SCOPED", 127}
}
    menu.add_feature("Change to Mixed Loot", "action", CAYO_SECONDARY.id, function()
    menu.notify("Secondary Target are now Mixed\n\nWhen using this method, the percentage and final payment is random!", "Heist Control", 3, 0xffef5a09)
    for i = 1, #SecondaryT_RDM do
        stat_set_int(SecondaryT_RDM[i][1], true, SecondaryT_RDM[i][2])
    end
end)
end

do
local SecondaryT_FCash = {
    {"H4LOOT_CASH_I", 0xFFFFFFF},
    {"H4LOOT_CASH_C", 0xFFFFFFF},
    {"H4LOOT_CASH_V", 90000},
    {"H4LOOT_WEED_I", 0},
    {"H4LOOT_WEED_C", 0},
    {"H4LOOT_WEED_V", 0},
    {"H4LOOT_COKE_I", 0},
    {"H4LOOT_COKE_C", 0},
    {"H4LOOT_COKE_V", 0},
    {"H4LOOT_GOLD_I", 0},
    {"H4LOOT_GOLD_C", 0},
    {"H4LOOT_GOLD_V", 0},
    {"H4LOOT_PAINT", 127},
    {"H4LOOT_PAINT_V", 190000},
    {"H4LOOT_CASH_I_SCOPED", 0xFFFFFFF},
    {"H4LOOT_CASH_C_SCOPED", 0xFFFFFFF},
    {"H4LOOT_WEED_I_SCOPED", 0},
    {"H4LOOT_WEED_C_SCOPED", 0},    
    {"H4LOOT_COKE_I_SCOPED", 0},
    {"H4LOOT_COKE_C_SCOPED", 0},
    {"H4LOOT_GOLD_I_SCOPED", 0},
    {"H4LOOT_GOLD_C_SCOPED", 0},
    {"H4LOOT_PAINT_SCOPED", 127}
}
    menu.add_feature("Change to full Cash", "action", CAYO_SECONDARY.id, function()
        menu.notify("Secondary Target are full Cash (only)\n\nWhen using this method, the percentage and final payment is random!", "Heist Control", 3, 0xffef5a09)
    for i = 1, #SecondaryT_FCash do
        stat_set_int(SecondaryT_FCash[i][1], true, SecondaryT_FCash[i][2])
    end
end)
end

do
local SecondaryT_FWeed = {
    {"H4LOOT_CASH_I", 0},
    {"H4LOOT_CASH_C", 0},
    {"H4LOOT_CASH_V", 0},
    {"H4LOOT_WEED_I", 0xFFFFFFF},
    {"H4LOOT_WEED_C", 0xFFFFFFF},
    {"H4LOOT_WEED_V", 140000},
    {"H4LOOT_COKE_I", 0},
    {"H4LOOT_COKE_C", 0},
    {"H4LOOT_COKE_V", 0},
    {"H4LOOT_GOLD_I", 0},
    {"H4LOOT_GOLD_C", 0},
    {"H4LOOT_GOLD_V", 0},
    {"H4LOOT_PAINT", 127},
    {"H4LOOT_PAINT_V", 190000},
    {"H4LOOT_CASH_I_SCOPED", 0},
    {"H4LOOT_CASH_C_SCOPED", 0},
    {"H4LOOT_WEED_I_SCOPED", 0xFFFFFFF},
    {"H4LOOT_WEED_C_SCOPED", 0xFFFFFFF},    
    {"H4LOOT_COKE_I_SCOPED", 0},
    {"H4LOOT_COKE_C_SCOPED", 0},
    {"H4LOOT_GOLD_I_SCOPED", 0},
    {"H4LOOT_GOLD_C_SCOPED", 0},
    {"H4LOOT_PAINT_SCOPED", 127}
}
    menu.add_feature("Change to full Weed", "action", CAYO_SECONDARY.id, function()
    menu.notify("Secondary Target are full Weed (only)\n\nWhen using this method, the percentage and final payment is random!", "Heist Control", 3, 0xffef5a09)
    for i = 1, #SecondaryT_FWeed do
        stat_set_int(SecondaryT_FWeed[i][1], true, SecondaryT_FWeed[i][2])
    end
end)
end

do
local SecondaryT_FCoke = {
    {"H4LOOT_CASH_I", 0},
    {"H4LOOT_CASH_C", 0},
    {"H4LOOT_CASH_V", 0},
    {"H4LOOT_WEED_I", 0},
    {"H4LOOT_WEED_C", 0},
    {"H4LOOT_WEED_V", 0},
    {"H4LOOT_COKE_I", 0xFFFFFFF},
    {"H4LOOT_COKE_C", 0xFFFFFFF},
    {"H4LOOT_COKE_V", 210000},
    {"H4LOOT_GOLD_I", 0},
    {"H4LOOT_GOLD_C", 0},
    {"H4LOOT_GOLD_V", 0},
    {"H4LOOT_PAINT", 127},
    {"H4LOOT_PAINT_V", 190000},
    {"H4LOOT_CASH_I_SCOPED", 0},
    {"H4LOOT_CASH_C_SCOPED", 0},
    {"H4LOOT_WEED_I_SCOPED", 0},
    {"H4LOOT_WEED_C_SCOPED", 0},    
    {"H4LOOT_COKE_I_SCOPED", 0xFFFFFFF},
    {"H4LOOT_COKE_C_SCOPED", 0xFFFFFFF},
    {"H4LOOT_GOLD_I_SCOPED", 0},
    {"H4LOOT_GOLD_C_SCOPED", 0},
    {"H4LOOT_PAINT_SCOPED", 127}
}
    menu.add_feature("Change to full Coke", "action", CAYO_SECONDARY.id, function()
        menu.notify("Secondary Target are full Coke (only)\n\nWhen using this method, the percentage and final payment is random!", "Heist Control", 3, 0xffef5a09)
    for i = 1, #SecondaryT_FCoke do
        stat_set_int(SecondaryT_FCoke[i][1], true, SecondaryT_FCoke[i][2])
    end
end)
end

do
local SecondaryT_FGold = {
    {"H4LOOT_CASH_I", 0},
    {"H4LOOT_CASH_C", 0},
    {"H4LOOT_CASH_V", 0},
    {"H4LOOT_WEED_I", 0},
    {"H4LOOT_WEED_C", 0},
    {"H4LOOT_WEED_V", 0},
    {"H4LOOT_COKE_I", 0},
    {"H4LOOT_COKE_C", 0},
    {"H4LOOT_COKE_V", 0},
    {"H4LOOT_GOLD_I", 0xFFFFFFF},
    {"H4LOOT_GOLD_C", 0xFFFFFFF},
    {"H4LOOT_GOLD_V", 320000},
    {"H4LOOT_PAINT", 0xFFFFFFF},
    {"H4LOOT_PAINT_V", 190000},
    {"H4LOOT_CASH_I_SCOPED", 0},
    {"H4LOOT_CASH_C_SCOPED", 0},
    {"H4LOOT_WEED_I_SCOPED", 0},
    {"H4LOOT_WEED_C_SCOPED", 0},    
    {"H4LOOT_COKE_I_SCOPED", 0},
    {"H4LOOT_COKE_C_SCOPED", 0},
    {"H4LOOT_GOLD_I_SCOPED", 0xFFFFFFF},
    {"H4LOOT_GOLD_C_SCOPED", 0xFFFFFFF},
    {"H4LOOT_PAINT_SCOPED", 0xFFFFFFF},
}
    menu.add_feature("Change to full Gold", "action", CAYO_SECONDARY.id, function()
    menu.notify("Secondary Target are full Gold (only)\n\nWhen using this method, the percentage and final payment is random!", "Heist Control", 3, 0xffef5a09)
    for i = 1, #SecondaryT_FGold do
        stat_set_int(SecondaryT_FGold[i][1], true, SecondaryT_FGold[i][2])
    end
end)
end

do
local SecondaryT_Remove = {
    {"H4LOOT_CASH_I", 0},
    {"H4LOOT_CASH_C", 0},
    {"H4LOOT_CASH_V", 0},
    {"H4LOOT_WEED_I", 0},
    {"H4LOOT_WEED_C", 0},
    {"H4LOOT_WEED_V", 0},
    {"H4LOOT_COKE_I", 0},
    {"H4LOOT_COKE_C", 0},
    {"H4LOOT_COKE_V", 0},
    {"H4LOOT_GOLD_I", 0},
    {"H4LOOT_GOLD_C", 0},
    {"H4LOOT_GOLD_V", 0},
    {"H4LOOT_PAINT", 0},
    {"H4LOOT_PAINT_V", 0},
    {"H4LOOT_CASH_I_SCOPED", 0},
    {"H4LOOT_CASH_C_SCOPED", 0},
    {"H4LOOT_WEED_I_SCOPED", 0},
    {"H4LOOT_WEED_C_SCOPED", 0},
    {"H4LOOT_COKE_I_SCOPED", 0},
    {"H4LOOT_COKE_C_SCOPED", 0},
    {"H4LOOT_GOLD_I_SCOPED", 0},
    {"H4LOOT_GOLD_C_SCOPED", 0},
    {"H4LOOT_PAINT_SCOPED", 0}
}
    menu.add_feature("Remove All", "action", CAYO_SECONDARY.id, function()
        menu.notify("All Secondary targets has been removed", "Heist Control", 3, 0xffef5a09)
        for i = 1, #SecondaryT_Remove do
        stat_set_int(SecondaryT_Remove[i][1], true, SecondaryT_Remove[i][2])
    end
    end)
end

local CAYO_COMPOUND = menu.add_feature("Compound Loot", "parent", CAYO_SECONDARY.id)

do
local Compound_LT_MIX = {
    {"H4LOOT_CASH_C", 2},
    {"H4LOOT_CASH_V", 474431},
    {"H4LOOT_WEED_C", 17},
    {"H4LOOT_WEED_V", 759090},
    {"H4LOOT_COKE_C", 132},
    {"H4LOOT_COKE_V", 948863},
    {"H4LOOT_GOLD_C", 104},
    {"H4LOOT_GOLD_V", 1265151},
    {"H4LOOT_PAINT", 127},
    {"H4LOOT_PAINT_V", 948863},
    {"H4LOOT_CASH_C_SCOPED", 2},
    {"H4LOOT_WEED_C_SCOPED", 17},
    {"H4LOOT_COKE_C_SCOPED", 132},
    {"H4LOOT_GOLD_C_SCOPED", 104},
    {"H4LOOT_PAINT_SCOPED", 127}
}
    menu.add_feature("Change to Mixed Loot", "action", CAYO_COMPOUND.id, function()
    menu.notify("Compound Loot has been modified", "Heist Control", 3, 0xffef5a09)
        for i = 1, #Compound_LT_MIX do
        stat_set_int(Compound_LT_MIX[i][1], true, Compound_LT_MIX[i][2])
        end
    end)
end

do
local Compound_LT_CASH = {
    {"H4LOOT_CASH_C", 0xFFFFFFF},
    {"H4LOOT_CASH_V", 90000},
    {"H4LOOT_WEED_C", 0},
    {"H4LOOT_WEED_V", 0},
    {"H4LOOT_COKE_C", 0},
    {"H4LOOT_COKE_V", 0},
    {"H4LOOT_GOLD_C", 0},
    {"H4LOOT_GOLD_V", 0},
    {"H4LOOT_PAINT", 127},
    {"H4LOOT_PAINT_V", 190000},
    {"H4LOOT_CASH_C_SCOPED", 0xFFFFFFF},
    {"H4LOOT_WEED_C_SCOPED", 0},
    {"H4LOOT_COKE_C_SCOPED", 0},
    {"H4LOOT_GOLD_C_SCOPED", 0},
    {"H4LOOT_PAINT_SCOPED", 127}
}
    menu.add_feature("Change to full Cash", "action", CAYO_COMPOUND.id, function()
    menu.notify("Compound Loot modified to Cash", "Heist Control", 3, 0xffef5a09)
        for i = 1, #Compound_LT_CASH do
        stat_set_int(Compound_LT_CASH[i][1], true, Compound_LT_CASH[i][2])
        end
    end)
end

do
local Compound_LT_WEED = {
    {"H4LOOT_CASH_C", 0},
    {"H4LOOT_CASH_V", 0},
    {"H4LOOT_WEED_C", 0xFFFFFFF},
    {"H4LOOT_WEED_V", 140000},
    {"H4LOOT_COKE_C", 0},
    {"H4LOOT_COKE_V", 0},
    {"H4LOOT_GOLD_C", 0},
    {"H4LOOT_PAINT", 127},
    {"H4LOOT_PAINT_V", 190000},
    {"H4LOOT_CASH_C_SCOPED", 0},
    {"H4LOOT_WEED_C_SCOPED", 0xFFFFFFF},
    {"H4LOOT_COKE_C_SCOPED", 0},
    {"H4LOOT_GOLD_C_SCOPED", 0},
    {"H4LOOT_PAINT_SCOPED", 127}
}
    menu.add_feature("Change to full Weed", "action", CAYO_COMPOUND.id, function()
    menu.notify("Compound Loot modified to Weed", "Heist Control", 3, 0xffef5a09)
        for i = 1, #Compound_LT_WEED do
        stat_set_int(Compound_LT_WEED[i][1], true, Compound_LT_WEED[i][2])
        end
    end)
end

do
local Compound_LT_COKE = {
    {"H4LOOT_CASH_C", 0},
    {"H4LOOT_CASH_V", 0},
    {"H4LOOT_WEED_C", 0},
    {"H4LOOT_WEED_V", 0},
    {"H4LOOT_COKE_C", 0xFFFFFFF},
    {"H4LOOT_COKE_V", 210000},
    {"H4LOOT_GOLD_C", 0},
    {"H4LOOT_PAINT", 127},
    {"H4LOOT_PAINT_V", 190000},
    {"H4LOOT_CASH_C_SCOPED", 0},
    {"H4LOOT_WEED_C_SCOPED", 0},
    {"H4LOOT_COKE_C_SCOPED", 0xFFFFFFF},
    {"H4LOOT_GOLD_C_SCOPED", 0},
    {"H4LOOT_PAINT_SCOPED", 127}
}
    menu.add_feature("Change to full Coke", "action", CAYO_COMPOUND.id, function()
    menu.notify("Compound Loot modified to Coke", "Heist Control", 3, 0xffef5a09)
        for i = 1, #Compound_LT_COKE do
        stat_set_int(Compound_LT_COKE[i][1], true, Compound_LT_COKE[i][2])
        end
    end)
end

do
local Compound_LT_GOLD = {
    {"H4LOOT_CASH_C", 0},
    {"H4LOOT_CASH_V", 0},
    {"H4LOOT_WEED_C", 0},
    {"H4LOOT_WEED_V", 0},
    {"H4LOOT_COKE_C", 0},
    {"H4LOOT_COKE_V", 0},
    {"H4LOOT_GOLD_C", 0xFFFFFFF},
    {"H4LOOT_GOLD_V", 320000},
    {"H4LOOT_PAINT", 127},
    {"H4LOOT_PAINT_V", 190000},
    {"H4LOOT_GOLD_C_SCOPED", 0xFFFFFFF},
    {"H4LOOT_CASH_C_SCOPED", 0},
    {"H4LOOT_WEED_C_SCOPED", 0},
    {"H4LOOT_COKE_C_SCOPED", 0},
    {"H4LOOT_PAINT_SCOPED", 127}
}
    menu.add_feature("Change to full Gold", "action", CAYO_COMPOUND.id, function()
        menu.notify("Compound Loot modified to Gold", "Heist Control", 3, 0xffef5a09)
        for i = 1, #Compound_LT_GOLD do
        stat_set_int(Compound_LT_GOLD[i][1], true, Compound_LT_GOLD[i][2])
    end
    end)
end

do
local Compound_LT_PAINT = {
    {"H4LOOT_CASH_C", 0},
    {"H4LOOT_CASH_V", 0},
    {"H4LOOT_WEED_C", 0},
    {"H4LOOT_WEED_V", 0},
    {"H4LOOT_COKE_C", 0},
    {"H4LOOT_COKE_V", 0},
    {"H4LOOT_GOLD_C", 0},
    {"H4LOOT_GOLD_V", 0},
    {"H4LOOT_GOLD_C_SCOPED", 0},
    {"H4LOOT_CASH_C_SCOPED", 0},
    {"H4LOOT_WEED_C_SCOPED", 0},
    {"H4LOOT_COKE_C_SCOPED", 0},
    {"H4LOOT_PAINT", 127},
    {"H4LOOT_PAINT_V", 190000},
    {"H4LOOT_PAINT_SCOPED", 127}
}
    menu.add_feature("Change to full Paint", "action", CAYO_COMPOUND.id, function()
        menu.notify("Compound Loot modified to Paint", "Heist Control", 3, 0xffef5a09)
        for i = 1, #Compound_LT_PAINT do
        stat_set_int(Compound_LT_PAINT[i][1], true, Compound_LT_PAINT[i][2])
    end
    end)
end

do
local Remove_Compound_Paint = {
    {"H4LOOT_PAINT", 0},
    {"H4LOOT_PAINT_V", 0},
    {"H4LOOT_PAINT_SCOPED", 0}
}
    menu.add_feature("Remove Paint (only)", "action", CAYO_COMPOUND.id, function()
    menu.notify("Paints has been removed", "Heist Control", 3, 0xffef5a09)
    for i = 1, #Remove_Compound_Paint do
    stat_set_int(Remove_Compound_Paint[i][1], true, Remove_Compound_Paint[i][2])
    end
    end)
end

do
local Remove_ALL_Compound_LT = {
    {"H4LOOT_CASH_C", 0},
    {"H4LOOT_WEED_C", 0},
    {"H4LOOT_COKE_C", 0},
    {"H4LOOT_GOLD_C", 0},
    {"H4LOOT_GOLD_C_SCOPED", 0},
    {"H4LOOT_CASH_C_SCOPED", 0},
    {"H4LOOT_WEED_C_SCOPED", 0},
    {"H4LOOT_COKE_C_SCOPED", 0},
    {"H4LOOT_PAINT", 0},
    {"H4LOOT_PAINT_SCOPED", 0}
}
    menu.add_feature("Remove all", "action", CAYO_COMPOUND.id, function()
        menu.notify("All Compound loots has been removed", "Heist Control", 3, 0xffef5a09)
        for i = 1, #Remove_ALL_Compound_LT do
        stat_set_int(Remove_ALL_Compound_LT[i][1], true, Remove_ALL_Compound_LT[i][2])
    end
    end)
end

do
local Weapon_Aggressor = {
    {"H4CNF_WEAPONS", 1}
}
    menu.add_feature("Aggressor Loadout", "action", CAYO_WEAPONS.id, function()
    menu.notify("Aggressor Loadout\n\nAssault SG + Machine Pistol\nMachete + Grenade", "Heist Control", 3, 0xffef5a09)
    for i = 1, #Weapon_Aggressor do
         stat_set_int(Weapon_Aggressor[i][1], true, Weapon_Aggressor[i][2])
        end
    end)
end

do
local Weapon_Conspirator = {
    {"H4CNF_WEAPONS", 2}
}
    menu.add_feature("Conspirator Loadout", "action", CAYO_WEAPONS.id, function()
    menu.notify("Conspirator Loadout\n\nMilitary Rifle + AP\nKnuckles + Stickies", "Heist Control", 3, 0xffef5a09)
    for i = 1, #Weapon_Conspirator do
        stat_set_int(Weapon_Conspirator[i][1], true, Weapon_Conspirator[i][2])
        end
    end)
end

do
local Weapon_Crackshot = {
    {"H4CNF_WEAPONS", 3}
}
    menu.add_feature("Crackshot Loadout", "action", CAYO_WEAPONS.id, function()
    menu.notify("Crackshot Loadout\n\nSniper + AP\nKnife + Molotov", "Heist Control", 3, 0xffef5a09)
    for i = 1, #Weapon_Crackshot do
        stat_set_int(Weapon_Crackshot[i][1], true, Weapon_Crackshot[i][2])
        end
    end)
end

do
local Weapon_Saboteur = {
    {"H4CNF_WEAPONS", 4}
}
    menu.add_feature("Saboteur Loadout", "action", CAYO_WEAPONS.id, function()
    menu.notify("Saboteur Loadout\n\nSMG MK II + SNS Pistol\nKnife + Pipe Bomb", "Heist Control", 3, 0xffef5a09)
    for i = 1, #Weapon_Saboteur do
        stat_set_int(Weapon_Saboteur[i][1], true, Weapon_Saboteur[i][2])
        end
    end)
end

do
local Weapon_Marksman = {
    {"H4CNF_WEAPONS", 5}
}
    menu.add_feature("Marksman Loadout", "action", CAYO_WEAPONS.id, function()
    menu.notify("Marksman Loadout\n\n- AK-47 + Pistol .50\n- Machete + Pipe Bomb", "Heist Control", 3, 0xffef5a09)
    for i = 1, #Weapon_Marksman do
        stat_set_int(Weapon_Marksman[i][1], true, Weapon_Marksman[i][2])
        end
    end)
end

do
local CP_Item_SpawnPlace_AIR = {
    {"H4CNF_GRAPPEL", 2022},
    {"H4CNF_UNIFORM", 12},
    {"H4CNF_BOLTCUT", 4161},
    {"H4CNF_TROJAN", 1}
}
    menu.add_feature("Set to Equipments spawn next to Airport", "action", CAYO_EQUIPM.id, function()
    menu.notify("Equipments will spawn next to Airport:\n\n- Grappling Hook\n- Guard Clothing\n- Bolt Cutters", "Heist Control", 3, 0xffef5a09)
    for i = 1, #CP_Item_SpawnPlace_AIR do
        stat_set_int(CP_Item_SpawnPlace_AIR[i][1], true, CP_Item_SpawnPlace_AIR[i][2])
        end
    end)
end

do
local CP_Item_SpawnPlace_DKS = {
    {"H4CNF_GRAPPEL", 3671},
    {"H4CNF_UNIFORM", 5256},
    {"H4CNF_BOLTCUT", 4424},
    {"H4CNF_TROJAN", 2}
}
    menu.add_feature("Set to Equipments spawn next to Docks", "action", CAYO_EQUIPM.id, function()
    menu.notify("Equipments will spawn next to Docks:\n\n- Grappling Hook\n- Guard Clothing\n- Bolt Cutters", "Heist Control", 3, 0xffef5a09)
    for i = 1, #CP_Item_SpawnPlace_DKS do
        stat_set_int(CP_Item_SpawnPlace_DKS[i][1], true, CP_Item_SpawnPlace_DKS[i][2])
        end
    end)
end

do
local CP_Item_SpawnPlace_CP = {
    {"H4CNF_GRAPPEL", 85324},
    {"H4CNF_UNIFORM", 61034},
    {"H4CNF_BOLTCUT", 4612},
    {"H4CNF_TROJAN", 5}
}
    menu.add_feature("Set to Equipments spawn next to Compound", "action", CAYO_EQUIPM.id, function()
    menu.notify("Equipments will spawn next to Compound:\n\n- Grappling Hook\n- Guard Clothing\n- Bolt Cutters", "Heist Control", 3, 0xffef5a09)
    for i = 1, #CP_Item_SpawnPlace_CP do
    stat_set_int(CP_Item_SpawnPlace_CP[i][1], true, CP_Item_SpawnPlace_CP[i][2])
    end
end)
end

do
local CP_TRUCK_SPAWN_mov1 = {
    {"H4CNF_TROJAN", 1}
}
    menu.add_feature("Modify Supply Truck spawn to Airport", "action", CAYO_TRUCK.id, function()
    menu.notify("Supply Truck will now spawn next to Airport", "Heist Control", 3, 0xffef5a09)
    for i = 1, #CP_TRUCK_SPAWN_mov1 do
    stat_set_int(CP_TRUCK_SPAWN_mov1[i][1], true, CP_TRUCK_SPAWN_mov1[i][2])
    end
    end)
end

do
local CP_TRUCK_SPAWN_mov2 = {
    {"H4CNF_TROJAN", 2}
}
    menu.add_feature("Modify Supply Truck spawn to North Dock", "action", CAYO_TRUCK.id, function()
    menu.notify("Supply Truck will now spawn next to North Dock", "Heist Control", 3, 0xffef5a09)
    for i = 1, #CP_TRUCK_SPAWN_mov2 do
     stat_set_int(CP_TRUCK_SPAWN_mov2[i][1], true, CP_TRUCK_SPAWN_mov2[i][2])
    end
    end)
end

do
local CP_TRUCK_SPAWN_mov3 = {
    {"H4CNF_TROJAN", 3}
}
    menu.add_feature("Modify Supply Truck spawn to Main Dock (East)", "action", CAYO_TRUCK.id, function()
    menu.notify("Supply Truck will now spawn next to Main Dock - East", "Heist Control", 3, 0xffef5a09)
    for i = 1, #CP_TRUCK_SPAWN_mov3 do
    stat_set_int(CP_TRUCK_SPAWN_mov3[i][1], true, CP_TRUCK_SPAWN_mov3[i][2])
    end
    end)
end

do
local CP_TRUCK_SPAWN_mov4 = {
    {"H4CNF_TROJAN", 4}
}
    menu.add_feature("Modify Supply Truck spawn to Main Dock (West)", "action", CAYO_TRUCK.id, function()
    menu.notify("Supply Truck will now spawn next to Main Dock (West)", "Heist Control", 3, 0xffef5a09)
    for i = 1, #CP_TRUCK_SPAWN_mov4 do
    stat_set_int(CP_TRUCK_SPAWN_mov4[i][1], true, CP_TRUCK_SPAWN_mov4[i][2])
    end
    end)
end

do
local CP_TRUCK_SPAWN_mov5 = {
    {"H4CNF_TROJAN", 5}
}
    menu.add_feature("Modify Supply Truck spawn next to Compound", "action", CAYO_TRUCK.id, function()
    menu.notify("Supply Truck will now spawn next to Compound", "Heist Control", 3, 0xffef5a09)
    for i = 1, #CP_TRUCK_SPAWN_mov5 do
    stat_set_int(CP_TRUCK_SPAWN_mov5[i][1], true, CP_TRUCK_SPAWN_mov5[i][2])
    end
    end)
end

do
local CAYO_NORMAL = {
    {"H4_PROGRESS", 126823}
}
    menu.add_feature("Change Difficulty to Normal", "action", CAYO_DFFCTY.id, function()
    menu.notify("Difficulty has been changed to Normal", "Difficulty Editor", 3, 0xffef5a09)
        for i = 1, #CAYO_NORMAL do
            stat_set_int(CAYO_NORMAL[i][1], true, CAYO_NORMAL[i][2])
        end
    end)
end

do
local CAYO_Hard = {
    {"H4_PROGRESS", 131055}
}
    menu.add_feature("Change Difficulty to Hard", "action", CAYO_DFFCTY.id, function()
    menu.notify("Difficulty has been changed to Hard", "Difficulty Editor", 3, 0xffef5a09)
        for i = 1, #CAYO_Hard do
            stat_set_int(CAYO_Hard[i][1], true, CAYO_Hard[i][2])
        end
    end)
end



do
menu.add_feature("Unlock Cayo Perico Awards", "action", MORE_OPTIONS.id, function()

local CP_AWRD_BL = {
    {"AWD_INTELGATHER", true},
    {"AWD_COMPOUNDINFILT", true},
    {"AWD_LOOT_FINDER", true},
    {"AWD_MAX_DISRUPT", true},
    {"AWD_THE_ISLAND_HEIST", true},
    {"AWD_GOING_ALONE", true},
    {"AWD_TEAM_WORK", true},
    {"AWD_MIXING_UP", true},
    {"AWD_PRO_THIEF", true},
    {"AWD_CAT_BURGLAR", true},
    {"AWD_ONE_OF_THEM", true},
    {"AWD_GOLDEN_GUN", true},
    {"AWD_ELITE_THIEF", true},
    {"AWD_PROFESSIONAL", true},
    {"AWD_HELPING_OUT", true},
    {"AWD_COURIER", true},
    {"AWD_PARTY_VIBES", true},
    {"AWD_HELPING_HAND", true},
    {"AWD_ELEVENELEVEN", true},
    {"COMPLETE_H4_F_USING_VETIR", true},
    {"COMPLETE_H4_F_USING_LONGFIN", true},
    {"COMPLETE_H4_F_USING_ANNIH", true},
    {"COMPLETE_H4_F_USING_ALKONOS", true},
    {"COMPLETE_H4_F_USING_PATROLB", true}
}
local CP_AWRD_IT = {
    {"AWD_LOSTANDFOUND", 500000},
    {"AWD_SUNSET", 1800000},
    {"AWD_TREASURE_HUNTER", 1000000},
    {"AWD_WRECK_DIVING", 1000000},
    {"AWD_KEINEMUSIK", 1800000},
    {"AWD_PALMS_TRAX", 1800000},
    {"AWD_MOODYMANN", 1800000},
    {"AWD_FILL_YOUR_BAGS", 1000000000},
    {"AWD_WELL_PREPARED", 80},
    {"H4_H4_DJ_MISSIONS", 0xFFFFFFF}
}
    menu.notify("Cayo Perico Awards Unlocked!", "Heist Control", 3, 0xffef5a09)
    for i = 1, #CP_AWRD_IT do
    stat_set_int(CP_AWRD_IT[i][1], true, CP_AWRD_IT[i][2])
    for i = 1, #CP_AWRD_BL do
    stat_set_bool(CP_AWRD_BL[i][1], true, CP_AWRD_BL[i][2])
    end
end
end)
end

do

local COMPLETE_CP_MISSIONS = {
    {"",},
    {"H4_MISSIONS", 0xFFFFFFF},
    {"H4CNF_APPROACH", 0xFFFFFFF},
    {"H4CNF_BS_ENTR", 63},
    {"H4CNF_BS_GEN", 63},
    {"H4CNF_WEP_DISRP", 3},
    {"H4CNF_ARM_DISRP", 3},
    {"H4CNF_HEL_DISRP", 3}
}
    menu.add_feature("Complete all Missions only", "action", MORE_OPTIONS.id, function()
    menu.notify("All missions are completed!", "Heist Control", 3, 0xffef5a09)
        for i = 1, #COMPLETE_CP_MISSIONS do
        stat_set_int(COMPLETE_CP_MISSIONS[i][1], true, COMPLETE_CP_MISSIONS[i][2])
        end
        end)
end

do
local WATCH_LONG_CUT = {
    {"H4_PLAYTHROUGH_STATUS", 0}
}
    menu.add_feature("Force the longest final Cutscene", "action", MORE_OPTIONS.id, function()
    menu.notify("Keep in mind that you must use this option before starting the Heist\n\nDone!", "Heist Control", 3, 0xffef5a09)
        for i = 1, #WATCH_LONG_CUT do
        stat_set_int(WATCH_LONG_CUT[i][1], true, WATCH_LONG_CUT[i][2])
    end
    end)
end

do
local CP_RST = {
    {"H4_MISSIONS", 0},
    {"H4_PROGRESS", 0},
    {"H4CNF_APPROACH", 0},
    {"H4CNF_BS_ENTR", 0},
    {"H4CNF_BS_GEN", 0},
    {"H4_PLAYTHROUGH_STATUS", 0}
}
    menu.add_feature("Reset Heist to Default", "action", MORE_OPTIONS.id, function()
    menu.notify("Process successfully completed", "", 3, 0x64FF78B4)
        for i = 1, #CP_RST do
        stat_set_int(CP_RST[i][1], true, CP_RST[i][2])
    end
    end)
end

---------- DISABLED FEATURE "REMOVE HEIST COOLDOWN" - CAYO PERICO 
--local CLD_RMV = {
   -- {"H4_COOLDOWN", 0},
   -- {"H4_COOLDOWN_HARD", 0},
   -- {"MPPLY_H4_COOLDOWN", 0}
--}
  --  menu.add_feature("Remove Heist Cooldown", "action", MORE_OPTIONS.id, function()
  --  menu.notify("Alert: This is NOT a bypass for the Server-Side Cooldown (Payout)\n\nPlease wait up to 15 minutes to avoid not receiving the money in the end", "Heist Control", 5, 0x641400E6)
  --      for i = 1, #CLD_RMV do
 --       stat_set_int(CLD_RMV[i][1], true, CLD_RMV[i][2])
 --       stat_set_int(CLD_RMV[i][1], false, CLD_RMV[i][2])
--end
--end)

---------------------- CASINO HEIST
do
local CH_RANDOM_PRST = {
    {"H3_COMPLETEDPOSIX", 0xFFFFFFF},
    {"CAS_HEIST_FLOW", 0xFFFFFFF},
    {"H3OPT_POI", 0xFFFFFFF},
    {"H3OPT_ACCESSPOINTS", 0xFFFFFFF},
    {"H3_LAST_APPROACH", 4},
    {"H3OPT_BITSET1", 0xFFFFFFF},
    {"H3OPT_DISRUPTSHIP", 3},
    {"H3OPT_BODYARMORLVL", 3},
    {"H3OPT_KEYLEVELS", 2},
    {"H3OPT_BITSET0", 0xFFFFFFF}
}
local CH_RANDOM_METHOD = {
    {"H3OPT_TARGET", 0,3,0,3},
    {"H3_HARD_APPROACH", 1,3,1,3},
    {"H3OPT_CREWWEAP", 1,5,1,5},
    {"H3OPT_CREWDRIVER", 1,5,1,5},
    {"H3OPT_CREWHACKER", 1,5,1,5},
    {"H3OPT_WEAPS", 0,1,0,1},
    {"H3OPT_VEHS", 0,3,0,3},
    {"H3OPT_MASKS", 1,12,1,12},
    {"H3OPT_APPROACH", 1,3,1,3}
}
    menu.add_feature("Load Random Approach", "action", CASINO_PRESETS.id, function()
    menu.notify("Make sure you have paid the heist on the planning screen before using this option\n\nRandom Preset Loaded!", "Heist Control", 3, 0x6414F0FF)
        for i = 1, #CH_RANDOM_PRST do
        stat_set_int(CH_RANDOM_PRST[i][1], true, CH_RANDOM_PRST[i][2])
        stat_set_int(CH_RANDOM_PRST[i][1], false, CH_RANDOM_PRST[i][2])
        end
        for i = 2, #CH_RANDOM_METHOD do
        stat_set_int(CH_RANDOM_METHOD[i][1], true, math.random(CH_RANDOM_METHOD[i][4], CH_RANDOM_METHOD[i][5]))
    end
end)
end

do
local CAH_SILENT_SNEAKY_HARD = {
    {"H3_COMPLETEDPOSIX", 0xFFFFFFF},
    {"CAS_HEIST_FLOW", 0xFFFFFFF},
    {"H3_LAST_APPROACH", 4},
    {"H3OPT_APPROACH", 1},
    {"H3_HARD_APPROACH", 1},
    {"H3OPT_TARGET", 3},
    {"H3OPT_POI", 0xFFFFFFF},
    {"H3OPT_ACCESSPOINTS", 0xFFFFFFF},
    {"H3OPT_BITSET1", 0xFFFFFFF},
    {"H3OPT_CREWWEAP", 4},
    {"H3OPT_CREWDRIVER", 5},
    {"H3OPT_CREWHACKER", 4},
    {"H3OPT_WEAPS", 1},
    {"H3OPT_VEHS", 1},
    {"H3OPT_DISRUPTSHIP", 3},
    {"H3OPT_BODYARMORLVL", 3},
    {"H3OPT_KEYLEVELS", 2},
    {"H3OPT_MASKS", 9},
    {"H3OPT_BITSET0", 0xFFFFFFF}
}
    menu.add_feature("Silent & Sneaky : (Hard)", "action", CASINO_PRESETS.id, function()
    menu.notify("Silent & Sneaky Approach Hard Difficulty\n\nTarget: Diamond\nVehicle: Vagrant\nDriver Crew: Chester McCoy\n\nWeapon: Carbine MK II\nGunman: Chester McCoy\n\nHacker: Avi Schwartzman\nUndetected: 3 minutes 30s\nDetected: 2 minutes 26s", "Heist Control", 6, 0x64F0AA14)
        for i = 1, #CAH_SILENT_SNEAKY_HARD do
        stat_set_int(CAH_SILENT_SNEAKY_HARD[i][1], true, CAH_SILENT_SNEAKY_HARD[i][2])
        end
    end)
end

do
local CAH_SILENT_SNEAKY = {
    {"H3_COMPLETEDPOSIX", 0xFFFFFFF},
    {"CAS_HEIST_FLOW", 0xFFFFFFF},
    {"H3_LAST_APPROACH", 4},
    {"H3OPT_APPROACH", 1},
    {"H3_HARD_APPROACH", 0},
    {"H3OPT_TARGET", 3},
    {"H3OPT_POI", 0xFFFFFFF},
    {"H3OPT_ACCESSPOINTS", 0xFFFFFFF},
    {"H3OPT_BITSET1", 0xFFFFFFF},
    {"H3OPT_CREWWEAP", 4},
    {"H3OPT_CREWDRIVER", 5},
    {"H3OPT_CREWHACKER", 4},
    {"H3OPT_WEAPS", 1},
    {"H3OPT_VEHS", 1},
    {"H3OPT_DISRUPTSHIP", 3},
    {"H3OPT_BODYARMORLVL", 3},
    {"H3OPT_KEYLEVELS", 2},
    {"H3OPT_MASKS", 9},
    {"H3OPT_BITSET0", 0xFFFFFFF}
}
    menu.add_feature("Silent & Sneaky : (Normal)", "action", CASINO_PRESETS.id, function()
    menu.notify("Silent & Sneaky Approach Normal Difficulty\n\nTarget: Diamond\nVehicle: Vagrant\nDriver Crew: Chester McCoy\n\nWeapon: Carbine MK II\nGunman: Chester McCoy\n\nHacker: Avi Schwartzman\nUndetected: 3 minutes 30s\nDetected: 2 minutes 26s", "Heist Control", 6, 0x64F0AA14)
    for i = 1, #CAH_SILENT_SNEAKY do
        stat_set_int(CAH_SILENT_SNEAKY[i][1], true, CAH_SILENT_SNEAKY[i][2])
    end
end)
end

do
local CAH_BIG_CON_HARD = {
    {"H3_COMPLETEDPOSIX", 0xFFFFFFF},
    {"CAS_HEIST_FLOW", 0xFFFFFFF},
    {"H3_LAST_APPROACH", 4},
    {"H3OPT_APPROACH", 2},
    {"H3_HARD_APPROACH", 2},
    {"H3OPT_TARGET", 3},
    {"H3OPT_POI", 0xFFFFFFF},
    {"H3OPT_ACCESSPOINTS", 0xFFFFFFF},
    {"H3OPT_BITSET1", 0xFFFFFFF},
    {"H3OPT_CREWWEAP", 4},
    {"H3OPT_CREWDRIVER", 5},
    {"H3OPT_CREWHACKER", 4},
    {"H3OPT_WEAPS", 1},
    {"H3OPT_VEHS", 1},
    {"H3OPT_DISRUPTSHIP", 3},
    {"H3OPT_BODYARMORLVL", 3},
    {"H3OPT_KEYLEVELS", 2},
    {"H3OPT_MASKS", 9},
    {"H3OPT_BITSET0", 0xFFFFFFF}
}
    menu.add_feature("The Big Con : (Hard)", "action", CASINO_PRESETS.id, function()
        menu.notify("BigCon Approach Hard Difficulty\n\nTarget: Diamond\nVehicle: Vagrant\nDriver Crew: Chester McCoy\n\nWeapon: SMG MK II\nGunman: Chester McCoy\n\nHacker: Avi Schwartzman\nUndetected: 3 minutes 30s\nDetected: 2 minutes 26s", "Heist Control", 6, 0x64F0AA14)
    for i = 1, #CAH_BIG_CON_HARD do
        stat_set_int(CAH_BIG_CON_HARD[i][1], true, CAH_BIG_CON_HARD[i][2])
    end
end)
end

do
local CAH_BIG_CON = {
    {"H3_COMPLETEDPOSIX", 0xFFFFFFF},
    {"CAS_HEIST_FLOW", 0xFFFFFFF},
    {"H3_LAST_APPROACH", 4},
    {"H3OPT_APPROACH", 2},
    {"H3_HARD_APPROACH", 0},
    {"H3OPT_TARGET", 3},
    {"H3OPT_POI", 0xFFFFFFF},
    {"H3OPT_ACCESSPOINTS", 0xFFFFFFF},
    {"H3OPT_BITSET1", 0xFFFFFFF},
    {"H3OPT_CREWWEAP", 4},
    {"H3OPT_CREWDRIVER", 5},
    {"H3OPT_CREWHACKER", 4},
    {"H3OPT_WEAPS", 0},
    {"H3OPT_VEHS", 1},
    {"H3OPT_DISRUPTSHIP", 3},
    {"H3OPT_BODYARMORLVL", 3},
    {"H3OPT_KEYLEVELS", 2},
    {"H3OPT_MASKS", 9},
    {"H3OPT_BITSET0", 0xFFFFFFF}
}
local RAM_MASK_3 = {
    {"H3OPT_MASKS", 1,12,12,1}
}
    menu.add_feature("The Big Con : (Normal)", "action", CASINO_PRESETS.id, function()
    menu.notify("BigCon Approach Normal Difficulty\n\nTarget: Diamond\nVehicle: Vagrant\nDriver Crew: Chester McCoy\n\nWeapon: SMG MK II\nGunman: Chester McCoy\n\nHacker: Avi Schwartzman\nUndetected: 3 minutes 30s\nDetected: 2 minutes 26s", "Heist Control", 6, 0x64F0AA14)
        for i = 1, #CAH_BIG_CON do
            stat_set_int(CAH_BIG_CON[i][1], true, CAH_BIG_CON[i][2])
        end
    end)
end

do
local CAH_AGGRESSIVE_HARD = {
    {"H3_COMPLETEDPOSIX", 0xFFFFFFF},
    {"CAS_HEIST_FLOW", 0xFFFFFFF},
    {"H3_LAST_APPROACH", 4},
    {"H3OPT_APPROACH", 3},
    {"H3_HARD_APPROACH", 3},
    {"H3OPT_TARGET", 3},
    {"H3OPT_POI", 0xFFFFFFF},
    {"H3OPT_ACCESSPOINTS", 0xFFFFFFF},
    {"H3OPT_BITSET1", 0xFFFFFFF},
    {"H3OPT_CREWWEAP", 4},
    {"H3OPT_CREWDRIVER", 5},
    {"H3OPT_CREWHACKER", 4},
    {"H3OPT_WEAPS", 1},
    {"H3OPT_VEHS", 1},
    {"H3OPT_DISRUPTSHIP", 3},
    {"H3OPT_BODYARMORLVL", 3},
    {"H3OPT_KEYLEVELS", 2},
    {"H3OPT_MASKS", 9},
    {"H3OPT_BITSET0", 0xFFFFFFF}
}
    menu.add_feature("Aggressive : (Hard)", "action", CASINO_PRESETS.id, function()
        menu.notify("Aggressive Approach Hard Difficulty\n\nTarget: Diamond\nVehicle: Vagrant\nDriver Crew: Chester McCoy\n\nWeapon: Assault Rifle MK II\nGunman: Chester McCoy\n\nHacker: Avi Schwartzman\nUndetected: 3 minutes 30s\nDetected: 2 minutes 26s", "Heist Control", 6, 0x64F0AA14)
        for i = 1, #CAH_AGGRESSIVE_HARD do
            stat_set_int(CAH_AGGRESSIVE_HARD[i][1], true, CAH_AGGRESSIVE_HARD[i][2])
        end
    end)
end

do
local CAH_AGGRESSIVE = {
    {"H3_COMPLETEDPOSIX", 0xFFFFFFF},
    {"CAS_HEIST_FLOW", 0xFFFFFFF},
    {"H3_LAST_APPROACH", 4},
    {"H3OPT_APPROACH", 3},
    {"H3_HARD_APPROACH", 0},
    {"H3OPT_TARGET", 3},
    {"H3OPT_POI", 0xFFFFFFF},
    {"H3OPT_ACCESSPOINTS", 0xFFFFFFF},
    {"H3OPT_BITSET1", 0xFFFFFFF},
    {"H3OPT_CREWWEAP", 4},
    {"H3OPT_CREWDRIVER", 5},
    {"H3OPT_CREWHACKER", 4},
    {"H3OPT_WEAPS", 1},
    {"H3OPT_VEHS", 1},
    {"H3OPT_DISRUPTSHIP", 3},
    {"H3OPT_BODYARMORLVL", 3},
    {"H3OPT_KEYLEVELS", 2},
    {"H3OPT_MASKS", 9},
    {"H3OPT_BITSET0", 0xFFFFFFF}
}
    menu.add_feature("Aggressive : (Normal)", "action", CASINO_PRESETS.id, function()
    menu.notify("Aggressive Approach Normal Difficulty\n\nTarget: Diamond\nVehicle: Vagrant\nDriver Crew: Chester McCoy\n\nWeapon: Assault Rifle MK II\nGunman: Chester McCoy\n\nHacker: Avi Schwartzman\nUndetected: 3 minutes 30s\nDetected: 2 minutes 26s", "Heist Control", 6, 0x64F0AA14)
        for i = 1, #CAH_AGGRESSIVE do
            stat_set_int(CAH_AGGRESSIVE[i][1], true, CAH_AGGRESSIVE[i][2])
        end
    end)
end

do
local CH_UNLCK_PT = {
    {"H3OPT_POI", 0xFFFFFFF},
    {"H3OPT_ACCESSPOINTS", 0xFFFFFFF}
}
    menu.add_feature("Unlock all Points of Interests & Access Points", "action", CASINO_BOARD1.id, function()
    menu.notify("Unlocked Successfully", "Heist Control", 3, 0x64FF7800)
        for i = 1, #CH_UNLCK_PT do
        stat_set_int(CH_UNLCK_PT[i][1], true, CH_UNLCK_PT[i][2])
        end
    end)
end

do
local CH_Target_Diamond = {
    {"H3OPT_TARGET", 3}
}
    menu.add_feature("Diamond", "action", CASINO_TARGET.id, function()
    menu.notify("Target changed to Diamond", "Target Editor", 3, 0x64F0AA14)
        for i = 1, #CH_Target_Diamond do
            stat_set_int(CH_Target_Diamond[i][1], true, CH_Target_Diamond[i][2])
        end
    end)
end

do
local CH_Target_Gold = {
    {"H3OPT_TARGET", 1}
}
    menu.add_feature("Gold", "action", CASINO_TARGET.id, function()
    menu.notify("Target changed to Gold", "Target Editor", 3, 0x64F0AA14)
        for i = 1, #CH_Target_Gold do
            stat_set_int(CH_Target_Gold[i][1], true, CH_Target_Gold[i][2])
        end
    end)
end

do
local CH_Target_Artwork = {
    {"H3OPT_TARGET", 2}
}
    menu.add_feature("Artwork", "action", CASINO_TARGET.id, function()
    menu.notify("Target changed to Artwork", "Target Editor", 3, 0x64F0AA14)
        for i = 1, #CH_Target_Artwork do
            stat_set_int(CH_Target_Artwork[i][1], true, CH_Target_Artwork[i][2])
        end
    end)
end

do
local CH_Target_Cash = {
    {"H3OPT_TARGET", 0}
}
    menu.add_feature("Cash", "action", CASINO_TARGET.id, function()
    menu.notify("Target changed to Cash", "Target Editor", 3, 0x64F0AA14)
        for i = 1, #CH_Target_Cash do
            stat_set_int(CH_Target_Cash[i][1], true, CH_Target_Cash[i][2])
        end
    end)
end
---- CASINO ADVANCED
do
    local SET_Diamond = {
    {"H3OPT_TARGET", 3}
    }
    local SET_NORMAL = {
    {"H3_LAST_APPROACH", 0},
    {"H3_HARD_APPROACH", 0}
}
    menu.add_feature("Increase Heist payout to 3.5 Millions (for all)", "toggle", CAH_ADVCED.id, function(hj)
    menu.notify("- Make sure you have chosen the preset before performing this function\n\n- Do not try to modify difficulty & players percentages\n\n- Do not attempt to modify the target (Diamond)\n\n- Use this option outside the arcade before starting the Heist", "", 16, 0x6414F0D2)
    menu.notify("Instructions\n\n- ALWAYS choose the cheapest buyer\n\n- ALWAYS use the Remove IA Crew Payout option before you escape through the tunnel\n\n- Collect the Diamond until you get 10 million (this is important)\n\n- Leave activated until the end", "", 16, 0x6414F0D2)
    ui.notify_above_map("~h~Heist Control has blocked changes to player percentages.\n\n~g~Host: 42%\nOthers players 25%", "", 96)
    ui.notify_above_map("~h~Estimated payout for each player\n~g~$3,600,000", "", 96)
    while hj.on do
    script.set_global_i(1703513+2326,42)
    script.set_global_i(1703513+2326+1,100)
    script.set_global_i(1703513+2326+2,100)
    script.set_global_i(1703513+2326+3,100)
    script.set_global_i(262145+28306,1410065408)
    for i = 1, #SET_Diamond do
    stat_set_int(SET_Diamond[i][1], true, SET_Diamond[i][2])
    end
    for i = 1, #SET_NORMAL do
    stat_set_int(SET_NORMAL[i][1], true, SET_NORMAL[i][2])
    end
    if not hj.on then return end
    system.wait(0)
    end
end)
end

    menu.add_feature("Increase potential gains", "toggle", CAH_ADVCED.id, function(gains)
    menu.notify("This option must be enabled before starting Heist. (Outside the arcade/garage)\n\nYou do not need to activate this option if you use the option to change the preset payment", "", 5, 0x6414F0FF)
    while gains.on do
    script.set_global_i(262145 + 28303, 1410065408) --Cash
    script.set_global_i(262145 + 28304, 1410065408) --Art
    script.set_global_i(262145 + 28305, 1410065408) --Gold
    script.set_global_i(262145 + 28306, 1410065408) --Diamond
    if not gains.on then return end
    system.wait(0)
    end
end)

local CAH_PLAYER_CUT = menu.add_feature("Players Payments", "parent", CAH_ADVCED.id, function()
    menu.notify("Important\n\n- Adding a high percentage can affect your payment negatively", "", 5, 0x6414F0FF)
end)

do
local your_cut_non_host=menu.add_feature("Your Cut Non-Host", "autoaction_value_i", CAH_PLAYER_CUT.id, function(a)
    script.set_global_i(2453903 + 6494, a.value)
end)


local your_cut=menu.add_feature("Your Cut", "autoaction_value_i", CAH_PLAYER_CUT.id, function(a)
    script.set_global_i(1703513 + 2326, a.value)
end)


local player2_cut=menu.add_feature("Player 2", "autoaction_value_i", CAH_PLAYER_CUT.id, function(a)
    script.set_global_i(1703513 + 2326 +1, a.value)
end)


local player3_cut=menu.add_feature("Player 3", "autoaction_value_i", CAH_PLAYER_CUT.id, function(a)
    script.set_global_i(1703513 + 2326 +2, a.value)
end)


local player4_cut=menu.add_feature("Player 4", "autoaction_value_i", CAH_PLAYER_CUT.id, function(a)
    script.set_global_i(1703513 + 2326 +3, a.value)
end)
your_cut_non_host.max,your_cut_non_host.min,your_cut_non_host.mod=100000,0,25
your_cut.max,your_cut.min,your_cut.mod=100000,0,25
player2_cut.max,player2_cut.min,player2_cut.mod=100000,0,25
player3_cut.max,player3_cut.min,player3_cut.mod=100000,0,25
player4_cut.max,player4_cut.min,player4_cut.mod=100000,0,25
menu.add_feature("give everyone 100% cut", "action", CAH_PLAYER_CUT.id, function()
    script.set_global_i(1703513 + 2326, 100)
    script.set_global_i(1703513 + 2326 +1, 100)
    script.set_global_i(1703513 + 2326 +2, 100)
    script.set_global_i(1703513 + 2326 +3, 100)
end)

local all_cuts=menu.add_feature("everyone's Cut", "action_value_i", CAH_PLAYER_CUT.id, function()
    script.set_global_i(1703513 + 2326, a.value)
    script.set_global_i(1703513 + 2326 +1, a.value)
    script.set_global_i(1703513 + 2326 +2, a.value)
    script.set_global_i(1703513 + 2326 +3, a.value)
end)
all_cuts.max,all_cuts.min,all_cuts.mod=100000,0,25
end


do
local CH_REM_CREW = {
    {"H3OPT_CREWWEAP", 6},
    {"H3OPT_CREWDRIVER", 6},
    {"H3OPT_CREWHACKER", 6}
}
menu.add_feature("Remove IA Crew Payout (0% NPC Cut)", "action", CAH_ADVCED.id, function()
    menu.notify("Use after stealing the target, before leaving the tunnel\n\nCrew removed", "Heist Control", 4, 0x64FF7800)
    for i = 1, #CH_REM_CREW do
    stat_set_int(CH_REM_CREW[i][1], true, CH_REM_CREW[i][2])
    end
end)
end
--- CASINO DIFFICULTY
do
local CH_Diff_Hard1 = {
    {"H3_LAST_APPROACH", 0},
    {"H3OPT_APPROACH", 1},
    {"H3_HARD_APPROACH", 1}
}
    menu.add_feature("Silent & Sneaky : Hard", "action", BOARD1_APPROACH.id, function()
    menu.notify("Approach changed to Silent and Sneaky (Hard)", "Heist Control", 3, 0x64FF7800)
        for i = 1, #CH_Diff_Hard1 do
        stat_set_int(CH_Diff_Hard1[i][1], true, CH_Diff_Hard1[i][2])
    end
end)
end

do
local CH_Diff_Normal1 = {
    {"H3_LAST_APPROACH", 0},
    {"H3OPT_APPROACH", 1},
    {"H3_HARD_APPROACH", 0}
}
    menu.add_feature("Silent & Sneaky : Normal", "action", BOARD1_APPROACH.id, function()
    menu.notify("Approach changed to Silent and Sneaky (Normal)", "Heist Control", 3, 0x64FF7800)
        for i = 1, #CH_Diff_Normal1 do
        stat_set_int(CH_Diff_Normal1[i][1], true, CH_Diff_Normal1[i][2])
        end
    end)
end


do
local CH_Diff_Hard2 = {
    {"H3_LAST_APPROACH", 0},
    {"H3OPT_APPROACH", 2},
    {"H3_HARD_APPROACH", 2}
}
    menu.add_feature("The Big Con : Hard", "action", BOARD1_APPROACH.id, function()
    menu.notify("Approach changed to BigCon (Hard)", "Heist Control", 3, 0x64FF7800)
        for i = 1, #CH_Diff_Hard2 do
        stat_set_int(CH_Diff_Hard2[i][1], true, CH_Diff_Hard2[i][2])
        end
     end)
end

do
local CH_Diff_Normal2 = {
    {"H3_LAST_APPROACH", 0},
    {"H3OPT_APPROACH", 2},
    {"H3_HARD_APPROACH", 0}
}
    menu.add_feature("The Big Con : Normal", "action", BOARD1_APPROACH.id, function()
    menu.notify("Approach changed to BigCon (Normal)", "Heist Control", 3, 0x64FF7800)
        for i = 1, #CH_Diff_Normal2 do
        stat_set_int(CH_Diff_Normal2[i][1], true, CH_Diff_Normal2[i][2])
    end
end)
end

do
local CH_Diff_Hard3 = {
    {"H3_LAST_APPROACH", 0},
    {"H3OPT_APPROACH", 3},
    {"H3_HARD_APPROACH", 0}
}
    menu.add_feature("Aggressive : Hard", "action", BOARD1_APPROACH.id, function()
    menu.notify("Approach changed to Aggressive (Hard)", "Heist Control", 3, 0x64FF7800)
            for i = 1, #CH_Diff_Hard3 do
            stat_set_int(CH_Diff_Hard3[i][1], true, CH_Diff_Hard3[i][2])
        end
    end)
end

do
local CH_Diff_Normal3 = {
    {"H3_LAST_APPROACH", 0},
    {"H3OPT_APPROACH", 3},
    {"H3_HARD_APPROACH", 0}
}
    menu.add_feature("Aggressive : Normal", "action", BOARD1_APPROACH.id, function()
    menu.notify("Approach changed to Aggressive (Normal)", "Heist Control", 3, 0x64FF7800)
         for i = 1, #CH_Diff_Normal3 do
         stat_set_int(CH_Diff_Normal3[i][1], true, CH_Diff_Normal3[i][2])
        end
    end)
end

local CASINO_GUNMAN = menu.add_feature("Change Gunman", "parent", CASINO_BOARD2.id)
do
local CH_GUNMAN_05 = {
    {"H3OPT_CREWWEAP", 4}
}
    menu.add_feature("Chester McCoy (10%)", "action", CASINO_GUNMAN.id, function()
    menu.notify("Chester McCoy now as Gunman\nCut 10%", "Heist Control", 3, 0x64F0AA14)
        for i = 1, #CH_GUNMAN_05 do
        stat_set_int(CH_GUNMAN_05[i][1], true, CH_GUNMAN_05[i][2])
        end
    end)
end

do
local CH_GUNMAN_04 = {
    {"H3OPT_CREWWEAP", 2}
}
    menu.add_feature("Gustavo Mota (9%)", "action", CASINO_GUNMAN.id, function()
    menu.notify("Gustavo Mota now as Gunman\nCut 9%", "Heist Control", 3, 0x64F0AA14)
        for i = 1, #CH_GUNMAN_04 do
        stat_set_int(CH_GUNMAN_04[i][1], true, CH_GUNMAN_04[i][2])
        end
end)
end

do
local CH_GUNMAN_03 = {
    {"H3OPT_CREWWEAP", 5}
}
    menu.add_feature("Patrick McReary (8%)", "action", CASINO_GUNMAN.id, function()
    menu.notify("Patrick McReary now as Gunman\nCut 8%", "Heist Control", 3, 0x64F0AA14)
        for i = 1, #CH_GUNMAN_03 do
        stat_set_int(CH_GUNMAN_03[i][1], true, CH_GUNMAN_03[i][2])
        end
    end)
end

do
local CH_GUNMAN_02 = {
    {"H3OPT_CREWWEAP", 3}
}
    menu.add_feature("Charlie Reed (7%)", "action", CASINO_GUNMAN.id, function()
    menu.notify("Charlie Reed now as Gunman\nCut 7%", "Heist Control", 3, 0x64F0AA14)
        for i = 1, #CH_GUNMAN_02 do
        stat_set_int(CH_GUNMAN_02[i][1], true, CH_GUNMAN_02[i][2])
        end
    end)
end

do
local CH_GUNMAN_01 = {
     {"H3OPT_CREWWEAP", 1}
}
    menu.add_feature("Karl Abolaji (5%)", "action", CASINO_GUNMAN.id, function()
    menu.notify("Karl Abolaji now as Gunman\nCut 5%", "Heist Control", 3, 0x64F0AA14)
        for i = 1, #CH_GUNMAN_01 do
        stat_set_int(CH_GUNMAN_01[i][1], true, CH_GUNMAN_01[i][2])
        end
    end)
end


do
local CH_GUNMAN_RND = {
    {"H3OPT_CREWWEAP", 1, 5, 1 ,5}
}
    menu.add_feature("Random Gunman Member (??%)", "action", CASINO_GUNMAN.id, function()
    menu.notify("Gunman Randomized\nCut ??", "RHeist Control", 3, 0x64F0AA14)
        for i = 1, #CH_GUNMAN_RND do
        stat_set_int(CH_GUNMAN_RND[i][1], true, math.random(CH_GUNMAN_RND[i][4], CH_GUNMAN_RND[i][5]))
         end
    end)
end

do
local CH_GUNMAN_00 = {
    {"H3OPT_CREWWEAP", 6}
}
menu.add_feature("Remove Gunman Member (0% Payout)", "action", CASINO_GUNMAN.id, function()
    menu.notify("Gunman Member Removed", "Heist Control", 3, 0x64F0AA14)
        for i = 1, #CH_GUNMAN_00 do
        stat_set_int(CH_GUNMAN_00[i][1], true, CH_GUNMAN_00[i][2])
        end
    end)
end

local CASINO_GUNMAN_var = menu.add_feature("Weapon Variation", "parent", CASINO_GUNMAN.id)

do
local CH_Gunman_var_01 = {
    {"H3OPT_WEAPS", 1}
}
    menu.add_feature("Best Variation", "action", CASINO_GUNMAN_var.id, function()
    menu.notify("Variation Changed to the Best", "Heist Control", 3, 0x64F0AA14)
    for i = 1, #CH_Gunman_var_01 do
    stat_set_int(CH_Gunman_var_01[i][1], true, CH_Gunman_var_01[i][2])
    end
end)
end

do
local CH_Gunman_var_00 = {
    {"H3OPT_WEAPS", 0}
}
    menu.add_feature("Worst Variation", "action", CASINO_GUNMAN_var.id, function()
    menu.notify("Variation Changed to the Worst", "Heist Control", 3, 0x64F0AA14)
        for i = 1, #CH_Gunman_var_00 do
        stat_set_int(CH_Gunman_var_00[i][1], true, CH_Gunman_var_00[i][2])
        end
    end)
end

local CASINO_DRIVER_TEAM = menu.add_feature("Change Driver", "parent", CASINO_BOARD2.id)

do
local CH_DRV_MAN_05 = {
    {"H3OPT_CREWDRIVER", 5}
}
    menu.add_feature("Chester McCoy (10%)", "action", CASINO_DRIVER_TEAM.id, function()
    menu.notify("Vehicle Variation Best\nVehicle: Everon 4 Seats\n\nVehicle Variation Good\nVehicle: Outlaw 2 Seats\n\nVehicle Variation Fine\nVehicle: Vagrant 2 Seats\n\nVehicle Variation Worst\nVehicle: Zhaba 4 Seats", "Chester McCoy Cut 10%", 5, 0x64F0AA14)
        for i = 1, #CH_DRV_MAN_05 do
        stat_set_int(CH_DRV_MAN_05[i][1], true, CH_DRV_MAN_05[i][2])
        end
    end)
end

do
local CH_DRV_MAN_04 = {
    {"H3OPT_CREWDRIVER", 3}
}
    menu.add_feature("Eddie Toh (9%)", "action", CASINO_DRIVER_TEAM.id, function()
    menu.notify("Vehicle Variation Best\nVehicle: Komoda 4 Seats\n\nVehicle Variation Good\nVehicle: Ellie 2 Seats\n\nVehicle Variation Fine\nVehicle: Gauntlet Classic 2 Seats\n\nVehicle Variation Worst\nVehicle: Sultan Classic 4 Seats", "Eddie Toh Cut 9%", 5, 0x64F0AA14)
        for i = 1, #CH_DRV_MAN_04 do
        stat_set_int(CH_DRV_MAN_04[i][1], true, CH_DRV_MAN_04[i][2])
        end
    end)
end

do
local CH_DRV_MAN_03 = {
    {"H3OPT_CREWDRIVER", 2}
}
    menu.add_feature("Taliana Martinez (7%)", "action", CASINO_DRIVER_TEAM.id, function()
    menu.notify("Vehicle Variation Best\nVehicle: Jugular 4 Seats\n\nVehicle Variation Good\nVehicle: Sugoi 4 Seats\n\nVehicle Variation: Fine\nVehicle Drift Yosemite 2 Seats\n\nVehicle Variation Worst\nVehicle: Retinue Mk II 2 Seats", "Taliana Martinez Cut 7%", 5, 0x64F0AA14)
        for i = 1, #CH_DRV_MAN_03 do
        stat_set_int(CH_DRV_MAN_03[i][1], true, CH_DRV_MAN_03[i][2])
        end
    end)
end

do
local CH_DRV_MAN_02 = {
    {"H3OPT_CREWDRIVER", 4}
}
    menu.add_feature("Zach Nelson (6%)", "action", CASINO_DRIVER_TEAM.id, function()
    menu.notify("Vehicle Variation Best\nVehicle: Lectro 2 Seats\n\nVehicle Variation Good\nVehicle: Defiler 1 Seat\n\nVehicle Variation Fine\nVehicle: Stryder 1 Seat\n\nVehicle Variation Worst\nVehicle: Manchez 2 Seats", "Zach Nelson Cut 6%", 5, 0x64F0AA14)
        for i = 1, #CH_DRV_MAN_02 do
        stat_set_int(CH_DRV_MAN_02[i][1], true, CH_DRV_MAN_02[i][2])
        end
end)
end

do
local CH_DRV_MAN_01 = {
    {"H3OPT_CREWDRIVER", 1}
}
    menu.add_feature("Karim Denz (5%)", "action", CASINO_DRIVER_TEAM.id, function()
    menu.notify("Vehicle Variation Best\nVehicle: Sentinel Classic 2 Seats\n\nVehicle Variation: Good\nVehicle: Kanjo 2 Seats\n\nVehicle Variation Fine\nVehicle: Asbo 2 Seats\n\nVehicle Variation Worst\nVehicle: Issi Classic 2 Seats", "Karim Denz Cut 5%", 5, 0x64F0AA14)
        for i = 1, #CH_DRV_MAN_01 do
        stat_set_int(CH_DRV_MAN_01[i][1], true, CH_DRV_MAN_01[i][2])
        end
end)
end

do
local CH_DRV_MAN_RND = {
    {"H3OPT_CREWDRIVER", 1, 5, 1 ,5}
}
    menu.add_feature("Random Driver Member", "action", CASINO_DRIVER_TEAM.id, function()
    menu.notify("Crew Driver randomized", "Heist Control", 3, 0x64F0AA14)
    for i = 1, #CH_DRV_MAN_RND do
    stat_set_int(CH_DRV_MAN_RND[i][1], true, math.random(CH_DRV_MAN_RND[i][4], CH_DRV_MAN_RND[i][5]))
    end
end)
end

do
local CH_DRV_MAN_00 = {
    {"H3OPT_CREWDRIVER", 6}
}
menu.add_feature("Remove Driver Member (0% Payout)", "action", CASINO_DRIVER_TEAM.id, function()
menu.notify("Driver Member Removed", "Heist Control", 3, 0x64F0AA14)
    for i = 1, #CH_DRV_MAN_00 do
    stat_set_int(CH_DRV_MAN_00[i][1], true, CH_DRV_MAN_00[i][2])
        end
    end)
end

local CAH_DRIVER_TEAM_var = menu.add_feature("Vehicle Variation", "parent", CASINO_DRIVER_TEAM.id)

do
local CH_DRV_MAN_var_03 = {
    {"H3OPT_VEHS", 3}
}
menu.add_feature("Best Variation", "action", CAH_DRIVER_TEAM_var.id, function()
menu.notify("Best Variation Selected", "Heist Control", 3, 0x64F0AA14)
    for i = 1, #CH_DRV_MAN_var_03 do
    stat_set_int(CH_DRV_MAN_var_03[i][1], true, CH_DRV_MAN_var_03[i][2])
    end
end)
end

do
local CH_DRV_MAN_var_02 = {
        {"H3OPT_VEHS", 2}
    }
    menu.add_feature("Good Variation", "action", CAH_DRIVER_TEAM_var.id, function()
    menu.notify("Good Variation", "Heist Control", 3, 0x64F0AA14)
        for i = 1, #CH_DRV_MAN_var_02 do
        stat_set_int(CH_DRV_MAN_var_02[i][1], true, CH_DRV_MAN_var_02[i][2])
        end
    end)
end
do
local CH_DRV_MAN_var_01 = {
    {"H3OPT_VEHS", 1}
}
    menu.add_feature("Fine Variation", "action", CAH_DRIVER_TEAM_var.id, function()
    menu.notify("Fine Variation", "Heist Control - Vehicle Variation", 3, 0x64F0AA14)
        for i = 1, #CH_DRV_MAN_var_01 do
        stat_set_int(CH_DRV_MAN_var_01[i][1], true, CH_DRV_MAN_var_01[i][2])
        end
    end)
end
do

local CH_DRV_MAN_var_00 = {
    {"H3OPT_VEHS", 0}
}
    menu.add_feature("Worst Variation", "action", CAH_DRIVER_TEAM_var.id, function()
    menu.notify("Worst Variation", "Heist Control", 3, 0x64F0AA14)
        for i = 1, #CH_DRV_MAN_var_00 do
        stat_set_int(CH_DRV_MAN_var_00[i][1], true, CH_DRV_MAN_var_00[i][2])
        end
    end)
end

do
local CH_DRV_MAN_var_RND = {
    {"H3OPT_VEHS", 0, 3, 0, 3}
}
    menu.add_feature("Random Car Variation", "action", CAH_DRIVER_TEAM_var.id, function()
    menu.notify("Car Randomized", "Heist Control", 3, 0x64F0AA14)
        for i = 1, #CH_DRV_MAN_var_RND do
        stat_set_int(CH_DRV_MAN_var_RND[i][1], true, math.random(CH_DRV_MAN_var_RND[i][4], CH_DRV_MAN_var_RND[i][5]))
        end
    end)
end

local CASINO_HACKERs = menu.add_feature("Change Hacker", "parent", CASINO_BOARD2.id)
do
local CH_HCK_MAN_04 = {
    {"H3OPT_CREWHACKER", 4}
}
    menu.add_feature("Avi Schwartzman (10%)", "action", CASINO_HACKERs.id, function()
    menu.notify("Name: Avi Schwartzman\nSkill: Expert\nTime Undetected: 3:30\nTime Detected: 2:26\nCut: 10%", "Heist Control", 5, 0x64F0AA14)
        for i = 1, #CH_HCK_MAN_04 do
        stat_set_int(CH_HCK_MAN_04[i][1], true, CH_HCK_MAN_04[i][2])
        end
end)
end

do
local CH_HCK_MAN_05 = {
    {"H3OPT_CREWHACKER", 5}
}
    menu.add_feature("Paige Harris (9%)", "action", CASINO_HACKERs.id, function()
    menu.notify("Name: Paige Harris\nSkill: Expert\nTime Undetected: 3:25\nTime Detected: 2:23\nCut: 9%", "Heist Control", 5, 0x64F0AA14)
        for i = 1, #CH_HCK_MAN_05 do
        stat_set_int(CH_HCK_MAN_05[i][1], true, CH_HCK_MAN_05[i][2])
        end
end)
end

do
local CH_HCK_MAN_03 = {
    {"H3OPT_CREWHACKER", 2}
}
    menu.add_feature("Christian Feltz (7%)", "action", CASINO_HACKERs.id, function()
    menu.notify("Name: Christian Feltz\nSkill: Good\nTime Undetected: 2:59\nTime Detected: 2:05\nCut: 7%", "Heist Control", 5, 0x64F0AA14)
        for i = 1, #CH_HCK_MAN_03 do
        stat_set_int(CH_HCK_MAN_03[i][1], true, CH_HCK_MAN_03[i][2])
        end
end)
end

do
local CH_HCK_MAN_02 = {
    {"H3OPT_CREWHACKER", 3}
}
    menu.add_feature("Yohan Blair (5%)", "action", CASINO_HACKERs.id, function()
    menu.notify("Name: Yohan Blair\nSkill: Good\nTime Undetected: 2:52\nTime Detected: 2:01\nCut: 5%", "Heist Control", 5, 0x64F0AA14)
        for i = 1, #CH_HCK_MAN_02 do
        stat_set_int(CH_HCK_MAN_02[i][1], true, CH_HCK_MAN_02[i][2])
        end
end)
end

do
local CH_HCK_MAN_01 = {
    {"H3OPT_CREWHACKER", 1}
}
    menu.add_feature("Rickie Luken (3%)", "action", CASINO_HACKERs.id, function()
    menu.notify("Name: Rickie Luken\nSkill: Poor\nTime Undetected: 2:26\nTime Detected: 1:42\nCut: 3%", "Heist Control - Hacker Member", 5, 0x64F0AA14)
        for i = 1, #CH_HCK_MAN_01 do
        stat_set_int(CH_HCK_MAN_01[i][1], true, CH_HCK_MAN_01[i][2])
        end
end)
end

do
local CH_HCK_MAN_RND = {
    {"H3OPT_CREWHACKER", 0, 5, 1, 5}
}
    menu.add_feature("Random Hacker Member", "action", CASINO_HACKERs.id, function()
    menu.notify("Hacker member randomized", "Heist Control", 4, 0x64F0AA14)
        for i = 1, #CH_HCK_MAN_RND do
        stat_set_int(CH_HCK_MAN_RND[i][1], true, math.random(CH_HCK_MAN_RND[i][4], CH_HCK_MAN_RND[i][5]))
        end
end)
end
do
local CH_HCK_MAN_00 = {
    {"H3OPT_CREWHACKER", 6}
}
    menu.add_feature("Remove Hacker Member (0% Payout)", "action", CASINO_HACKERs.id, function()
    menu.notify("Hacker member removed", "Heist Control", 4, 0x64F0AA14)
        for i = 1, #CH_HCK_MAN_00 do
        stat_set_int(CH_HCK_MAN_00[i][1], true, CH_HCK_MAN_00[i][2])
        end
    end)
end

local CASINO_MASK = menu.add_feature("Choose Mask", "parent", CASINO_BOARD2.id)

do
local CH_MASK_00 = {
    {"H3OPT_MASKS", 0xFFFFFFF}
}
    menu.add_feature("Remove Mask", "action", CASINO_MASK.id, function()
    menu.notify("Mask: Removed", "Heist Control", 2, 0x64F0AA14)
        for i = 1, #CH_MASK_00 do
        stat_set_int(CH_MASK_00[i][1], true, CH_MASK_00[i][2])
        end
end)
end

do
local CH_MASK_01 = {
    {"H3OPT_MASKS", 1}
}
    menu.add_feature("Geometric Set", "action", CASINO_MASK.id, function()
    menu.notify("Mask: Geometric", "Heist Control", 2, 0x64F0AA14)
        for i = 1, #CH_MASK_01 do
        stat_set_int(CH_MASK_01[i][1], true, CH_MASK_01[i][2])
        end
end)
end

do
local CH_MASK_02 = {
    {"H3OPT_MASKS", 2}
}
    menu.add_feature("Hunter Set", "action", CASINO_MASK.id, function()
    menu.notify("Mask: Hunter", "Heist Control", 2, 0x64F0AA14)
        for i = 1, #CH_MASK_02 do
        stat_set_int(CH_MASK_02[i][1], true, CH_MASK_02[i][2])
        end
end)
end

do
local CH_MASK_03 = {
    {"H3OPT_MASKS", 3}
}
    menu.add_feature("Oni Half Mask Set", "action", CASINO_MASK.id, function()
    menu.notify("Mask: Oni Half Mask", "Heist Control", 2, 0x64F0AA14)
        for i = 1, #CH_MASK_03 do
    stat_set_int(CH_MASK_03[i][1], true, CH_MASK_03[i][2])
        end
    end)
end

do
local CH_MASK_04 = {
    {"H3OPT_MASKS", 4}
}
    menu.add_feature("Emoji Set", "action", CASINO_MASK.id, function()
    menu.notify("Mask: Emoji", "Heist Control", 2, 0x64F0AA14)
        for i = 1, #CH_MASK_04 do
        stat_set_int(CH_MASK_04[i][1], true, CH_MASK_04[i][2])
        end
end)
end

do
local CH_MASK_05 = {
    {"H3OPT_MASKS", 5}
}
    menu.add_feature("Ornate Skull Set", "action", CASINO_MASK.id, function()
    menu.notify("Mask: Ornate Skull", "Heist Control", 2, 0x64F0AA14)
        for i = 1, #CH_MASK_05 do
        stat_set_int(CH_MASK_05[i][1], true, CH_MASK_05[i][2])
        end
end)
end

do
local CH_MASK_06 = {
     {"H3OPT_MASKS", 6}
}
    menu.add_feature("Lucky Fruit Set", "action", CASINO_MASK.id, function()
    menu.notify("Mask: Lucky Fruit", "Heist Control", 2, 0x64F0AA14)
        for i = 1, #CH_MASK_06 do
        stat_set_int(CH_MASK_06[i][1], true, CH_MASK_06[i][2])
         end
end)
end

do
local CH_MASK_07 = {
    {"H3OPT_MASKS", 7}
}
    menu.add_feature("Guerilla Set", "action", CASINO_MASK.id, function()
    menu.notify("Mask: Guerilla", "Heist Control", 2, 0x64F0AA14)
        for i = 1, #CH_MASK_07 do
        stat_set_int(CH_MASK_07[i][1], true, CH_MASK_07[i][2])
        end
end)
end

do
local CH_MASK_08 = {
    {"H3OPT_MASKS", 8}
}
    menu.add_feature("Clown Set", "action", CASINO_MASK.id, function()
    menu.notify("Mask: Clown", "Heist Control", 2, 0x64F0AA14)
    for i = 1, #CH_MASK_08 do
     stat_set_int(CH_MASK_08[i][1], true, CH_MASK_08[i][2])
    end
end)
end

do
local CH_MASK_09 = {
    {"H3OPT_MASKS", 9}
}
    menu.add_feature("Animal Set", "action", CASINO_MASK.id, function()
    menu.notify("Mask: Animal", "Heist Control", 2, 0x64F0AA14)
        for i = 1, #CH_MASK_09 do
        stat_set_int(CH_MASK_09[i][1], true, CH_MASK_09[i][2])
        end
end)
end

do
local CH_MASK_10 = {
    {"H3OPT_MASKS", 10}
}
    menu.add_feature("Riot Set", "action", CASINO_MASK.id, function()
    menu.notify("Mask: Riot", "Heist Control", 2, 0x64F0AA14)
        for i = 1, #CH_MASK_10 do
        stat_set_int(CH_MASK_10[i][1], true, CH_MASK_10[i][2])
        end
end)
end

do
local CH_MASK_11 = {
    {"H3OPT_MASKS", 11}
}
    menu.add_feature("Oni Set", "action", CASINO_MASK.id, function()
    menu.notify("Mask: Oni Set", "Heist Control", 2, 0x64F0AA14)
        for i = 1, #CH_MASK_11 do
        stat_set_int(CH_MASK_11[i][1], true, CH_MASK_11[i][2])
        end
end)
end

do
local CH_MASK_12 = {
    {"H3OPT_MASKS", 12}
}
    menu.add_feature("Hocket Set", "action", CASINO_MASK.id, function()
    menu.notify("Mask: Hockey Set", "Heist Control", 2, 0x64F0AA14)
        for i = 1, #CH_MASK_12 do
        stat_set_int(CH_MASK_12[i][1], true, CH_MASK_12[i][2])
    end
end)
end

do
    local CH_DUGGAN = {
{"H3OPT_DISRUPTSHIP", 3}
}
local CH_SCANC_LVL = {
    {"H3OPT_KEYLEVELS", 2}
}
    menu.add_feature("Unlock Scan Card LVL 2", "action", CASINO_BOARD2.id, function()
    menu.notify("Scan Card LVL 2 Unlocked", "Heist Control", 2, 0x64F0AA14)
        for i = 1, #CH_SCANC_LVL do
        stat_set_int(CH_SCANC_LVL[i][1], true, CH_SCANC_LVL[i][2])
    end
end)
   
    menu.add_feature("Weaken Duggan Guards", "action", CASINO_BOARD2.id, function()
    menu.notify("Duggan Guards Weakened", "Heist Control", 2, 0x64F0AA14)
        for i = 1, #CH_DUGGAN do
        stat_set_int(CH_DUGGAN[i][1], true, CH_DUGGAN[i][2])
    end
end)
end

do
    local CH_UNLCK_3stboard_var1 = {
        {"H3OPT_BITSET0", -8849}
    }
    local CH_UNLCK_3stboard_var3bc = {
        {"H3OPT_BITSET0", -186}
    }
    menu.add_feature("Remove Drill for Silent and Aggressive only", "action", CASINO_BOARD3.id, function()
    menu.notify("Drill removed for Silent and Aggressive Approach", "Heist Control", 3, 0x64F06414)
    for i = 1, #CH_UNLCK_3stboard_var1 do
        stat_set_int(CH_UNLCK_3stboard_var1[i][1], true, CH_UNLCK_3stboard_var1[i][2])
     end
end)
    menu.add_feature("Remove Drill for The Big Con only", "action", CASINO_BOARD3.id, function()
     menu.notify("Drill removed for BigCon", "Heist Control", 3, 0x64F06414)
    for i = 1, #CH_UNLCK_3stboard_var3bc do
        stat_set_int(CH_UNLCK_3stboard_var3bc[i][1], true, CH_UNLCK_3stboard_var3bc[i][2])
        end
    end)
end

do
local CH_LOAD_BOARD_var0 = {
    {"H3OPT_BITSET1", 0xFFFFFFF},
    {"H3OPT_BITSET0", 0xFFFFFFF}
}
local CH_UNLOAD_BOARD_var1 = {
    {"H3OPT_BITSET1", 0},
    {"H3OPT_BITSET0", 0}
}
menu.add_feature("Load all Boards", "action", CASINO_LBOARDS.id, function()
    menu.notify("All Planning Board Loaded", "Heist Control", 3, 0x6400FA14)
    for i = 1, #CH_LOAD_BOARD_var0 do
        stat_set_int(CH_LOAD_BOARD_var0[i][1], true, CH_LOAD_BOARD_var0[i][2])
    end
end)

menu.add_feature("Unload all Boards", "action", CASINO_LBOARDS.id, function()
    menu.notify("All Planning Board Unloaded", "Heist Control", 3, 0x641400FF)
    for i = 1, #CH_UNLOAD_BOARD_var1 do
        stat_set_int(CH_UNLOAD_BOARD_var1[i][1], true, CH_UNLOAD_BOARD_var1[i][2])
    end
end)
end

do
local CH_AWRD_BL = {
    {"AWD_FIRST_TIME1", true},
    {"AWD_FIRST_TIME2", true},
    {"AWD_FIRST_TIME3", true},
    {"AWD_FIRST_TIME4", true},
    {"AWD_FIRST_TIME5", true},
    {"AWD_FIRST_TIME6", true},
    {"AWD_ALL_IN_ORDER", true},
    {"AWD_SUPPORTING_ROLE", true},
    {"AWD_LEADER", true},
    {"AWD_ODD_JOBS", true},
    {"AWD_SURVIVALIST", true},
    {"AWD_SCOPEOUT", true},
    {"AWD_CREWEDUP", true},
    {"AWD_MOVINGON", true},
    {"AWD_PROMOCAMP", true},
    {"AWD_GUNMAN", true},
    {"AWD_SMASHNGRAB", true},
    {"AWD_INPLAINSI", true},
    {"AWD_UNDETECTED", true},
    {"AWD_ALLROUND", true},
    {"AWD_ELITETHEIF", true},
    {"AWD_PRO", true},
    {"AWD_SUPPORTACT", true},
    {"AWD_SHAFTED", true},
    {"AWD_COLLECTOR", true},
    {"AWD_DEADEYE", true},
    {"AWD_PISTOLSATDAWN", true},
    {"AWD_TRAFFICAVOI", true},
    {"AWD_CANTCATCHBRA", true},
    {"AWD_WIZHARD", true},
    {"AWD_APEESCAPE", true},
    {"AWD_MONKEYKIND", true},
    {"AWD_AQUAAPE", true},
    {"AWD_KEEPFAITH", true},
    {"AWD_TRUELOVE", true},
    {"AWD_NEMESIS", true},
    {"AWD_FRIENDZONED", true},
    {"VCM_FLOW_CS_RSC_SEEN", true},
    {"VCM_FLOW_CS_BWL_SEEN", true},
    {"VCM_FLOW_CS_MTG_SEEN", true},
    {"VCM_FLOW_CS_OIL_SEEN", true},
    {"VCM_FLOW_CS_DEF_SEEN", true},
    {"VCM_FLOW_CS_FIN_SEEN", true},
    {"CAS_VEHICLE_REWARD", false},
    {"HELP_FURIA", true},
    {"HELP_MINITAN", true},
    {"HELP_YOSEMITE2", true},
    {"HELP_ZHABA", true},
    {"HELP_IMORGEN", true},
    {"HELP_SULTAN2", true},
    {"HELP_VAGRANT", true},
    {"HELP_VSTR", true},
    {"HELP_STRYDER", true},
    {"HELP_SUGOI", true},
    {"HELP_KANJO", true},
    {"HELP_FORMULA", true},
    {"HELP_FORMULA2", true},
    {"HELP_JB7002", true}
}
local CH_AWRD_IT = {
    {"CAS_HEIST_NOTS", 0xFFFFFFF},
    {"CH_ARC_CAB_CLAW_TROPHY", 0xFFFFFFF},
    {"CH_ARC_CAB_LOVE_TROPHY", 0xFFFFFFF},
    {"SIGNAL_JAMMERS_COLLECTED", 50},
    {"AWD_ODD_JOBS", 52},
    {"AWD_PREPARATION", 40},
    {"AWD_ASLEEPONJOB", 20},
    {"AWD_DAICASHCRAB", 100000},
    {"AWD_BIGBRO", 40},
    {"AWD_SHARPSHOOTER", 40},
    {"AWD_RACECHAMP", 40},
    {"AWD_BATSWORD", 1000000},
    {"AWD_COINPURSE", 950000},
    {"AWD_ASTROCHIMP", 3000000},
    {"AWD_MASTERFUL", 40000},
    {"H3_BOARD_DIALOGUE0", 0xFFFFFFF},
    {"H3_BOARD_DIALOGUE1", 0xFFFFFFF},
    {"H3_BOARD_DIALOGUE2", 0xFFFFFFF},
    {"H3_VEHICLESUSED", 0xFFFFFFF}
}
    menu.add_feature("Unlock Casino Awards", "action", CASINO_MORE.id, function()
    menu.notify("Casino Heist Awards Unlocked", "Heist Control", 3, 0x6400FA14)
    for i = 1, #CH_AWRD_IT do
        stat_set_int(CH_AWRD_IT[i][1], true, CH_AWRD_IT[i][2])
    for i = 2, #CH_AWRD_BL do
        stat_set_bool(CH_AWRD_BL[i][1], true, CH_AWRD_BL[i][2])
            end
        end
    end)
end

do
local CLD_CH_RMV = {
    {"MPPLY_H3_COOLDOWN", 0xFFFFFFF},
    {"H3_COMPLETEDPOSIX", 0xFFFFFFF}
}
    menu.add_feature("Remove Heist Prepare Cooldown", "action", CASINO_MORE.id, function()
    menu.notify("This is not a bypass for the server-side cooldown (payment)", "Heist Control", 3, 0x6414F0FF)
    for i = 1, #CLD_CH_RMV do
        stat_set_int(CLD_CH_RMV[i][1], true, CLD_CH_RMV[i][2])
        stat_set_int(CLD_CH_RMV[i][1], false, CLD_CH_RMV[i][2])
        end
    end)
end

do
local AGATHA_MS_INT= {
    {"VCM_FLOW_PROGRESS", 0xFFFFFFF},
    {"VCM_STORY_PROGRESS", 5}
}
local AGATHA_MS_BOL = {
    {"AWD_LEADER", true},
    {"VCM_FLOW_CS_FIN_SEEN", true}
}
menu.add_feature("Skip Agatha Baker missions to the last one", "action", CASINO_MORE.id, function()
    menu.notify("Your wish was successfully granted", "", 5, 0x64F078F0)
    for i = 1, #AGATHA_MS_INT do
        stat_set_int(AGATHA_MS_INT[i][1], true, AGATHA_MS_INT[i][2])
    end
    for i = 2, #AGATHA_MS_BOL do
        stat_set_bool(AGATHA_MS_BOL[i][1], true, AGATHA_MS_BOL[i][2])
    end
end)
end

do
local CH_RST = {
    {"H3_LAST_APPROACH", 0},
    {"H3OPT_APPROACH", 0},
    {"H3_HARD_APPROACH", 0},
    {"H3OPT_TARGET", 0},
    {"H3OPT_POI", 0},
    {"H3OPT_ACCESSPOINTS", 0},
    {"H3OPT_BITSET1", 0},
    {"H3OPT_CREWWEAP", 0},
    {"H3OPT_CREWDRIVER", 0},
    {"H3OPT_CREWHACKER", 0},
    {"H3OPT_WEAPS", 0},
    {"H3OPT_VEHS", 0},
    {"H3OPT_DISRUPTSHIP", 0},
    {"H3OPT_BODYARMORLVL", 0},
    {"H3OPT_KEYLEVELS", 0},
    {"H3OPT_MASKS", 0},
    {"H3OPT_BITSET0", 0}
}
menu.add_feature("Reset Heist to Default", "action", CASINO_MORE.id, function()
    menu.notify("Call to Lester and tell him to cancel the Casino Heist", "Heist Control", 3, 0x64FF78B4)
for i = 1, #CH_RST do
    stat_set_int(CH_RST[i][1], true, CH_RST[i][2])
end
end)
end
-------- DOOMSDAY HEIST
do
local DD_H_ACT1 = {
    {"GANGOPS_FLOW_MISSION_PROG", 503},
    {"GANGOPS_HEIST_STATUS", -229383},
    {"GANGOPS_FLOW_NOTIFICATIONS", 1557}
}
    menu.add_feature("ACT I : The Data Breaches [Final Heist]", "action", DOOMS_PRESETS.id, function()
    menu.notify("[ACT 1] The Data Breaches\n\nReady to play", "", 4, 0x64FF78B4)
    for i = 1, #DD_H_ACT1 do
        stat_set_int(DD_H_ACT1[i][1], true, DD_H_ACT1[i][2])
    end
end)
end

do
local DD_H_ACT2 = {
    {"GANGOPS_FLOW_MISSION_PROG", 240},
    {"GANGOPS_HEIST_STATUS", -229378},
    {"GANGOPS_FLOW_NOTIFICATIONS", 1557}
}
    menu.add_feature("ACT II : The Bogdan Problem [Final Heist]", "action", DOOMS_PRESETS.id, function()
    menu.notify("[ACT 2] The Bogdan Problem\n\nReady to play", "", 4, 0x64FF78B4)
    for i = 1, #DD_H_ACT2 do
        stat_set_int(DD_H_ACT2[i][1], true, DD_H_ACT2[i][2])
    end
end)
end

do
local DD_H_ACT3 = {
    {"GANGOPS_FLOW_MISSION_PROG", 16368},
    {"GANGOPS_HEIST_STATUS", -229380},
    {"GANGOPS_FLOW_NOTIFICATIONS", 1557}
}
    menu.add_feature("ACT III : The Doomsday Scenario [Final Heist]", "action", DOOMS_PRESETS.id, function()
    menu.notify("[ACT 3] The Doomsday Scenario\n\nReady to play", "", 4, 0x64FF78B4)
    for i = 1, #DD_H_ACT3 do
        stat_set_int(DD_H_ACT3[i][1], true, DD_H_ACT3[i][2])
    end
end)
end
do
    local my_cut2=menu.add_feature("Your Cut", "autoaction_value_i", DDHEIST_PLYR_MANAGER.id, function(p)
        script.set_global_i(1699568+812+50+1, p.value)
    end)
    my_cut2.max,my_cut2.min,my_cut2.mod=100000,0,25
    end
    
    do
    local player2_cut2=menu.add_feature("Player 2", "autoaction_value_i", DDHEIST_PLYR_MANAGER.id, function(p)
        script.set_global_i(1699568+812+50+2, p.value)
    end)
    player2_cut2.max,player2_cut2.min,player2_cut2.mod=100000,0,25
    end
    
    do
    local player3_cut2=menu.add_feature("Player 3", "autoaction_value_i", DDHEIST_PLYR_MANAGER.id, function(p)
        script.set_global_i(1699568+812+50+3, p.value)
    end)
    player3_cut2.max,player3_cut2.min,player3_cut2.mod=100000,0,25
    end
    
    do
    local player4_cut2=menu.add_feature("Player 4", "autoaction_value_i", DDHEIST_PLYR_MANAGER.id, function(p)
        script.set_global_i(1699568+812+50+4, p.value)
    end)
    player4_cut2.max,player4_cut2.min,player4_cut2.mod=100000,0,25
    end

menu.add_feature("Increase 'ACT II' Heist Payout to 2.4 Millions (for all)", "toggle", DDHEIST_PLYR_MANAGER.id, function(act)
    menu.notify("For ACT II (Bogdan Problem) only\nPut it on hard difficulty, don't worry if it shows different percentages in-game\n\nLeave activated until the end of the heist", "Heist Control", 6, 0x6414F0FF)
    ui.notify_above_map("~h~Heist Control has blocked changes to player percentages.\n\n~g~All Players: 205 %", "", 96)
    ui.notify_above_map("~h~Estimated payout for each player\n~g~$2,400,000", "", 96)
    while act.on do
    script.set_global_i(1699568+812+50+1, 205)
    script.set_global_i(1699568+812+50+2, 205)
    script.set_global_i(1699568+812+50+3, 205)
    script.set_global_i(1699568+812+50+4, 205)
    if not act.on then return end
    system.wait(0)
end
end)


do
local DD_H_ULCK = {
    {"GANGOPS_HEIST_STATUS", 0xFFFFFFF},
    {"GANGOPS_HEIST_STATUS", -229384}
}
    menu.add_feature("Unlock all Doomsday Heist", "action", DOOMS_HEIST.id, function()
    menu.notify("Call the Lester and ask to cancel the Doomsday Heist (Three Times)\nDo this only once", "Heist Control", 4, 0x64F06414)
    for i = 1, #DD_H_ULCK do
    stat_set_int(DD_H_ULCK[i][1], true, DD_H_ULCK[i][2])
    end
    end)
end

do
local DD_PREPS_DONE = {
    {"GANGOPS_FM_MISSION_PROG", 0xFFFFFFF}
}
    menu.add_feature("Complete all preparations (Not setups)", "action", DOOMS_HEIST.id, function()
        menu.notify("All Preps are completed", "Heist Control", 3, 0x64F06414)
        for i = 1, #DD_PREPS_DONE do
            stat_set_int(DD_PREPS_DONE[i][1], true, DD_PREPS_DONE[i][2])
        end
    end)
end

do
local DD_H_RST = {
    {"GANGOPS_FLOW_MISSION_PROG", 240},
    {"GANGOPS_HEIST_STATUS", 0},
    {"GANGOPS_FLOW_NOTIFICATIONS", 1557}
}
    menu.add_feature("Reset Heist to Default", "action", DOOMS_HEIST.id, function()
    menu.notify("Doomsday restored\nGo to a new session!!!", "Heist Control", 3, 0x64F06414)
        for i = 1, #DD_H_RST do
        stat_set_int(DD_H_RST[i][1], true, DD_H_RST[i][2])
        end
    end)
    end
do
    local DD_AWARDS_I = {
    {"GANGOPS_FM_MISSION_PROG", 0xFFFFFFF},
    {"GANGOPS_FLOW_MISSION_PROG", 0xFFFFFFF},
    {"MPPLY_GANGOPS_ALLINORDER", 100},
    {"MPPLY_GANGOPS_LOYALTY", 100},
    {"MPPLY_GANGOPS_CRIMMASMD", 100},
    {"MPPLY_GANGOPS_LOYALTY2", 100},
    {"MPPLY_GANGOPS_LOYALTY3", 100},
    {"MPPLY_GANGOPS_CRIMMASMD2", 100},
    {"MPPLY_GANGOPS_CRIMMASMD3", 100},
    {"MPPLY_GANGOPS_SUPPORT", 100},
    {"CR_GANGOP_MORGUE", 10},
    {"CR_GANGOP_DELUXO", 10},
    {"CR_GANGOP_SERVERFARM", 10},
    {"CR_GANGOP_IAABASE_FIN", 10},
    {"CR_GANGOP_STEALOSPREY", 10},
    {"CR_GANGOP_FOUNDRY", 10},
    {"CR_GANGOP_RIOTVAN", 10},
    {"CR_GANGOP_SUBMARINECAR", 10},
    {"CR_GANGOP_SUBMARINE_FIN", 10},
    {"CR_GANGOP_PREDATOR", 10},
    {"CR_GANGOP_BMLAUNCHER", 10},
    {"CR_GANGOP_BCCUSTOM", 10},
    {"CR_GANGOP_STEALTHTANKS", 10},
    {"CR_GANGOP_SPYPLANE", 10},
    {"CR_GANGOP_FINALE", 10},
    {"CR_GANGOP_FINALE_P2", 10},
    {"CR_GANGOP_FINALE_P3", 10}
}
local DD_AWARDS_B = {
    {"MPPLY_AWD_GANGOPS_IAA", true},
    {"MPPLY_AWD_GANGOPS_SUBMARINE", true},
    {"MPPLY_AWD_GANGOPS_MISSILE", true},
    {"MPPLY_AWD_GANGOPS_ALLINORDER", true},
    {"MPPLY_AWD_GANGOPS_LOYALTY", true},
    {"MPPLY_AWD_GANGOPS_LOYALTY2", true},
    {"MPPLY_AWD_GANGOPS_LOYALTY3", true},
    {"MPPLY_AWD_GANGOPS_CRIMMASMD", true},
    {"MPPLY_AWD_GANGOPS_CRIMMASMD2", true},
    {"MPPLY_AWD_GANGOPS_CRIMMASMD3", true}
}
    menu.add_feature("Unlock Doomsday Heist Awards", "action", DOOMS_HEIST.id, function()
    menu.notify("Doomsday Awards Unlocked", "Heist Control", 3, 0x6400FA14)
    for i = 1, #DD_AWARDS_I do
        stat_set_int(DD_AWARDS_I[i][1], true, DD_AWARDS_I[i][2])
        stat_set_int(DD_AWARDS_I[i][1], false, DD_AWARDS_I[i][2])
    for i = 1, #DD_AWARDS_B do
        stat_set_bool(DD_AWARDS_B[i][1], true, DD_AWARDS_B[i][2])
        stat_set_bool(DD_AWARDS_B[i][1], false, DD_AWARDS_B[i][2])
        end
    end
    end)
end
-------- CLASSIC HEIST
do
local my_cut3=menu.add_feature("Your Cut", "autoaction_value_i", CLASSIC_HEISTS.id, function(a)
    script.set_global_i(1671773 + 3008 +1, a.value)
end)
my_cut3.max,my_cut3.min,my_cut3.mod=100000,0,25
end

do
local Apartment_AWD_B = {
    {"MPPLY_AWD_COMPLET_HEIST_MEM", true},
    {"MPPLY_AWD_COMPLET_HEIST_1STPER", true},
    {"MPPLY_AWD_FLEECA_FIN", true},
    {"MPPLY_AWD_HST_ORDER", true},
    {"MPPLY_AWD_HST_SAME_TEAM", true},
    {"MPPLY_AWD_HST_ULT_CHAL", true},
    {"MPPLY_AWD_HUMANE_FIN", true},
    {"MPPLY_AWD_PACIFIC_FIN", true},
    {"MPPLY_AWD_PRISON_FIN", true},
    {"MPPLY_AWD_SERIESA_FIN", true},
    {"AWD_FINISH_HEIST_NO_DAMAGE", true},
    {"AWD_SPLIT_HEIST_TAKE_EVENLY", true},
    {"AWD_ALL_ROLES_HEIST", true},
    {"AWD_MATCHING_OUTFIT_HEIST", true},
    {"HEIST_PLANNING_DONE_PRINT", true},
    {"HEIST_PLANNING_DONE_HELP_0", true},
    {"HEIST_PLANNING_DONE_HELP_1", true},
    {"HEIST_PRE_PLAN_DONE_HELP_0", true},
    {"HEIST_CUTS_DONE_FINALE", true},
    {"HEIST_IS_TUTORIAL", false},
    {"HEIST_STRAND_INTRO_DONE", true},
    {"HEIST_CUTS_DONE_ORNATE", true},
    {"HEIST_CUTS_DONE_PRISON", true},
    {"HEIST_CUTS_DONE_BIOLAB", true},
    {"HEIST_CUTS_DONE_NARCOTIC", true},
    {"HEIST_CUTS_DONE_TUTORIAL", true},
    {"HEIST_AWARD_DONE_PREP", true},
    {"HEIST_AWARD_BOUGHT_IN", true}
}
    local Apartment_AWD_I = {
    {"AWD_FINISH_HEISTS", 900},
    {"MPPLY_WIN_GOLD_MEDAL_HEISTS", 900},
    {"AWD_DO_HEIST_AS_MEMBER", 900},
    {"AWD_DO_HEIST_AS_THE_LEADER", 900},
    {"AWD_FINISH_HEIST_SETUP_JOB", 900},
    {"AWD_FINISH_HEIST", 900},
    {"HEIST_COMPLETION", 900},
    {"HEISTS_ORGANISED", 900},
    {"AWD_CONTROL_CROWDS", 900},
    {"AWD_WIN_GOLD_MEDAL_HEISTS", 900},
    {"AWD_COMPLETE_HEIST_NOT_DIE", 900},
    {"HEIST_START", 900},
    {"HEIST_END", 900},
    {"CUTSCENE_MID_PRISON", 900},
    {"CUTSCENE_MID_HUMANE", 900},
    {"CUTSCENE_MID_NARC", 900},
    {"CUTSCENE_MID_ORNATE", 900},
    {"CR_FLEECA_PREP_1", 5000},
    {"CR_FLEECA_PREP_2", 5000},
    {"CR_FLEECA_FINALE", 5000},
    {"CR_PRISON_PLANE", 5000},
    {"CR_PRISON_BUS", 5000},
    {"CR_PRISON_STATION", 5000},
    {"CR_PRISON_UNFINISHED_BIZ", 5000},
    {"CR_PRISON_FINALE", 5000},
    {"CR_HUMANE_KEY_CODES", 5000},
    {"CR_HUMANE_ARMORDILLOS", 5000},
    {"CR_HUMANE_EMP", 5000},
    {"CR_HUMANE_VALKYRIE", 5000},
    {"CR_HUMANE_FINALE", 5000},
    {"CR_NARC_COKE", 5000},
    {"CR_NARC_TRASH_TRUCK", 5000},
    {"CR_NARC_BIKERS", 5000},
    {"CR_NARC_WEED", 5000},
    {"CR_NARC_STEAL_METH", 5000},
    {"CR_NARC_FINALE", 5000},
    {"CR_PACIFIC_TRUCKS ", 5000},
    {"CR_PACIFIC_WITSEC", 5000},
    {"CR_PACIFIC_HACK", 5000},
    {"CR_PACIFIC_BIKES", 5000},
    {"CR_PACIFIC_CONVOY", 5000},
    {"CR_PACIFIC_FINALE", 5000},
    {"MPPLY_HEIST_ACH_TRACKER", 0xFFFFFFF}
}
    menu.add_feature("Unlock All Awards & All Classic Heists", "action", CLASSIC_HEISTS.id, function()
    menu.notify("- All achievements unlocked\n\n- All Classic Heists unlocked\n\nSwitch session or restart the game to take effect", "", 6, 0x64FF7800)
    for i = 1, #Apartment_AWD_I do
    stat_set_int(Apartment_AWD_I[i][1], true, Apartment_AWD_I[i][2])
    stat_set_int(Apartment_AWD_I[i][1], false, Apartment_AWD_I[i][2])
    for i = 1, #Apartment_AWD_B do
    stat_set_bool(Apartment_AWD_B[i][1], true, Apartment_AWD_B[i][2])
    stat_set_bool(Apartment_AWD_B[i][1], false, Apartment_AWD_B[i][2])
end
end
end)
end

do
local Apartment_SetDone = {
    {"HEIST_PLANNING_STAGE", 0xFFFFFFF}
}
    menu.add_feature("Complete all setups", "toggle", CLASSIC_HEISTS.id, function(checkin)
    menu.notify("You may need to choose a Heist and then complete the first setup\n\nLet activated until then ;)", "", 7, 0x50FF78B4)
    while checkin.on do
    for i = 1, #Apartment_SetDone do
    stat_set_int(Apartment_SetDone[i][1], true, Apartment_SetDone[i][2])
    if not checkin.on then return end
    system.wait(1000)
    end
end
end)
end

menu.add_feature("Fleeca Heist $15 MILLIONs (You only)", "toggle", CLASSIC_HEISTS.id, function(a)
    menu.notify("Use only when you need money\n\nUsing it more than 5 times a day can be dangerous\n\nDeactivate only at the end of the Heist.", "", 12, 0x6414F0FF)
    menu.notify("You have to be the Host\n\nEnable this option when entering the percentage (payment) screen\n\nDoes not work for player 2 (avoid changing it)", "", 12, 0x6414F0FF)
    while a.on do
    script.set_global_i(1671773 + 3008 +1,10434)
    if not a.on then return end
    system.wait(0)
    end
end)

menu.add_feature("Fleeca Heist $10 MILLIONs (You only)", "toggle", CLASSIC_HEISTS.id, function(ab)
    menu.notify("Use only when you need money\n\nUsing it more than 5 times a day can be dangerous\n\nDeactivate only at the end of the Heist.", "", 12, 0x6414F0FF)
    menu.notify("You have to be the Host\n\nEnable this option when entering the percentage (payment) screen\n\nDoes not work for player 2 (avoid changing it)", "", 12, 0x6414F0FF)
    while ab.on do
    script.set_global_i(1671773 + 3008 +1,7000)
    if not ab.on then return end
    system.wait(0)
    end
end)

menu.add_feature("Fleeca Heist $5 MILLIONs (You only)", "toggle", CLASSIC_HEISTS.id, function(ab)
    menu.notify("Use only when you need money\n\nUsing it more than 5 times a day can be dangerous\n\nDeactivate only at the end of the Heist.", "", 12, 0x6414F0FF)
    menu.notify("You have to be the Host\n\nEnable this option when entering the percentage (payment) screen\n\nDoes not work for player 2 (avoid changing it)", "", 12, 0x6414F0FF)
    while ab.on do
    script.set_global_i(1671773 + 3008 +1,3500)
    if not ab.on then return end
    system.wait(0)
    end
end)

-- CLASSIC CUT WEEKLY EVENT
menu.add_feature("[2x EVENT] Fleeca Heist $15 MILLIONs (You only)", "toggle", CLASSIC_HEISTS.id, function(eg)
    menu.notify("Use only when you need money\n\nUsing it more than 5 times a day can be dangerous\n\nIt should only be used when an event is activated.", "", 12, 0x6414F0FF)
    menu.notify("You have to be the Host\n\nEnable this option when entering the percentage (payment) screen\n\nDoes not work for player 2 (avoid changing it)", "", 12, 0x6414F0FF)
    while eg.on do
    script.set_global_i(1671773+3008+1, 5217)
    if not eg.on then return end
    system.wait(0)
    end
end)
    
menu.add_feature("[2x EVENT] Fleeca Heist $10 MILLIONs (You only)", "toggle", CLASSIC_HEISTS.id, function(eg)
    menu.notify("Use only when you need money\n\nUsing it more than 5 times a day can be dangerous\n\nIt should only be used when an event is activated", "", 12, 0x6414F0FF)
    menu.notify("You have to be the Host\n\nEnable this option when entering the percentage (payment) screen\n\nDoes not work for player 2 (avoid changing it)", "", 12, 0x6414F0FF)
    while eg.on do
    script.set_global_i(1671773+3008+1, 3500)
    if not eg.on then return end
    system.wait(0)
    end
end)

menu.add_feature("[2x EVENT] Fleeca Heist $5 MILLIONs (You only)", "toggle", CLASSIC_HEISTS.id, function(eg)
    menu.notify("Use only when you need money\n\nUsing it more than 5 times a day can be dangerous\n\nIt should only be used when an event is activated.", "", 12, 0x6414F0FF)
    menu.notify("You have to be the Host\n\nEnable this option when entering the percentage (payment) screen\n\nDoes not work for player 2 (avoid changing it)", "", 12, 0x6414F0FF)
    while eg.on do
    script.set_global_i(1671773+3008+1, 1750)
    if not eg.on then return end
    system.wait(0)
    end
end)

------------- LS CONTRACTS
    menu.add_feature("Increase Payout to 1 Million", "toggle", LS_ROBBERY.id, function(rob)
    menu.notify("Always keep this option actived before starting a contract\n\nThere is a cooldown for the payment, it can be between 15-20 minutes if you plan to repeat.\n\nAffects you only","Heist Control", 7, 0x6400FA14)
    while rob.on do
        script.set_global_i(262145+30515+0,1000000)
        script.set_global_i(262145+30515+1,1000000)
        script.set_global_i(262145+30515+2,1000000)
        script.set_global_i(262145+30515+3,1000000)
        script.set_global_i(262145+30515+4,1000000)
        script.set_global_i(262145+30515+5,1000000)
        script.set_global_i(262145+30515+6,1000000)
        script.set_global_i(262145+30515+7,1000000)
        script.set_global_i(292668,1000000)
        script.set_global_i(262145+30514,1000000) -- reward when joining a contract
        script.set_global_i(262145+30511,0) -- IA cut removal
    if not rob.on then return end
    system.wait(0)
    end
end)

menu.add_feature("[2x GTA$ RP EVENT] :: Increase payout to 1 Million", "toggle", LS_ROBBERY.id, function(rob0)
    menu.notify("Always keep this option actived before starting a contract\n\nThere is a cooldown for the payment, it can be between 15-20 minutes if you plan to repeat.\n\nAffects you only","Heist Control", 7, 0x6400FA14)
    menu.notify("Note: This option should only be used when the double event (2x XP and GTA$) is enabled!\n\nThe payment may appear as 500,000, but in fact you will grab 1 million", "", 7, 0x6400FA14)
        while rob0.on do
        script.set_global_i(262145+30515+0,500000)
        script.set_global_i(262145+30515+1,500000)
        script.set_global_i(262145+30515+2,500000)
        script.set_global_i(262145+30515+3,500000)
        script.set_global_i(262145+30515+4,500000)
        script.set_global_i(262145+30515+5,500000)
        script.set_global_i(262145+30515+6,500000)
        script.set_global_i(262145+30515+7,500000)
        script.set_global_i(292668,500000)
        script.set_global_i(262145+30514,500000) -- reward when joining a contract
        script.set_global_i(262145+30511,0) -- IA cut removal
    if not rob0.on then return end
    system.wait(0)
    end
end)

do
local LS_CONTRACT_0_UD = {
    {"TUNER_GEN_BS", 12543},
    {"TUNER_CURRENT", 0}
}
    menu.add_feature("Union Depository", "action", LS_ROBBERY.id, function()
        for i = 1, #LS_CONTRACT_0_UD do
        menu.notify("For immediate effect... It is recommended that you stay outside from your Workshop!\n\nChoosed: Union Depository Contract", "", 6, 0x64F06414)
        stat_set_int(LS_CONTRACT_0_UD[i][1], true, LS_CONTRACT_0_UD[i][2])
    end
    end)
end

do
local LS_CONTRACT_1_SD = {
     {"TUNER_GEN_BS", 4351},
    {"TUNER_CURRENT", 1}
}
    menu.add_feature("The Superdollar Deal", "action", LS_ROBBERY.id, function()
        for i = 1, #LS_CONTRACT_1_SD do
        menu.notify("For immediate effect... It is recommended that you stay outside from your Workshop!\n\nChoosed: The Superdollar Deal Contract", "", 6, 0x64F06414)
        stat_set_int(LS_CONTRACT_1_SD[i][1], true, LS_CONTRACT_1_SD[i][2])
    end
    end)
end

do
local LS_CONTRACT_2_BC = {
    {"TUNER_GEN_BS", 12543},
    {"TUNER_CURRENT", 2}
}
    menu.add_feature("The Bank Contract", "action", LS_ROBBERY.id, function()
    for i = 1, #LS_CONTRACT_2_BC do
    menu.notify("For immediate effect... It is recommended that you stay outside from your Workshop!\n\nChoosed: The Bank Contract", "", 6, 0x64F06414)
    stat_set_int(LS_CONTRACT_2_BC[i][1], true, LS_CONTRACT_2_BC[i][2])
    end
    end)
end

do
local LS_CONTRACT_3_ECU = {
    {"TUNER_GEN_BS", 12543},
    {"TUNER_CURRENT", 3}
}
    menu.add_feature("The ECU Job", "action", LS_ROBBERY.id, function()
        for i = 1, #LS_CONTRACT_3_ECU do
        menu.notify("For immediate effect... It is recommended that you stay outside from your Workshop!\n\nChoosed: The ECU Job Contract", "", 6, 0x64F06414)
        stat_set_int(LS_CONTRACT_3_ECU[i][1], true, LS_CONTRACT_3_ECU[i][2])
    end
    end)
end

do
local LS_CONTRACT_4_PRSN = {
    {"TUNER_GEN_BS", 12543},
    {"TUNER_CURRENT", 4}
} 
    menu.add_feature("The Prison Contract", "action", LS_ROBBERY.id, function()
        for i = 1, #LS_CONTRACT_4_PRSN do
        menu.notify("For immediate effect... It is recommended that you stay outside from your Workshop!\n\nChoosed: The Prison Contract", "", 6, 0x64F06414)
        stat_set_int(LS_CONTRACT_4_PRSN[i][1], true, LS_CONTRACT_4_PRSN[i][2])
    end
    end)
end

do
local LS_CONTRACT_5_AGC = {
    {"TUNER_GEN_BS", 12543},
    {"TUNER_CURRENT", 5}
}
    menu.add_feature("The Agency Deal", "action", LS_ROBBERY.id, function()
        for i = 1, #LS_CONTRACT_5_AGC do
        menu.notify("For immediate effect... It is recommended that you stay outside from your Workshop!\n\nChoosed: The Agency Deal Contract", "", 6, 0x64F06414)
        stat_set_int(LS_CONTRACT_5_AGC[i][1], true, LS_CONTRACT_5_AGC[i][2])
    end
    end)
end

do
local LS_CONTRACT_6_LOST = {
    {"TUNER_GEN_BS", 12543},
    {"TUNER_CURRENT", 6}
}
    menu.add_feature("The Lost Contract", "action", LS_ROBBERY.id, function()
    for i = 1, #LS_CONTRACT_6_LOST do
    menu.notify("For immediate effect... It is recommended that you stay outside from your Workshop!\n\nChoosed: The Lost Contract", "", 6, 0x64F06414)
    stat_set_int(LS_CONTRACT_6_LOST[i][1], true, LS_CONTRACT_6_LOST[i][2])
    end
    end)
end

do
local LS_CONTRACT_7_DATA = {
    {"TUNER_GEN_BS", 12543},
    {"TUNER_CURRENT", 7}
}
    menu.add_feature("The Data Contract", "action", LS_ROBBERY.id, function()
        for i = 1, #LS_CONTRACT_7_DATA do
        menu.notify("For immediate effect... It is recommended that you stay outside from your Workshop!\n\nChoosed: The Data Contract", "", 6, 0x64F06414)
        menu.notify("Ignoring some dialogues between npc's can prevent you from getting paid, please don't teleport too often!", "Important", 6, 0x6414F0FF)
        stat_set_int(LS_CONTRACT_7_DATA[i][1], true, LS_CONTRACT_7_DATA[i][2])
    end
    end)
end

do
local LS_CONTRACT_MSS_ONLY = {
    {"TUNER_GEN_BS", 0xFFFFFFF}
}
    menu.add_feature("Complete missions (only)", "action", LS_ROBBERY.id, function()
    for i = 1, #LS_CONTRACT_MSS_ONLY do
    menu.notify("Changes will only happen if you are outside your Auto-Shop\n\nMissions completed","Heist Control", 6, 0x64F06414)
    stat_set_int(LS_CONTRACT_MSS_ONLY[i][1], true, LS_CONTRACT_MSS_ONLY[i][2])
    end
    end)
end

local ROBBERY_RESETER = menu.add_feature("»More", "parent", LS_ROBBERY.id)

do
local LS_CONTRACT_MISSION_RST = {
    {"TUNER_GEN_BS", 12467}
}
menu.add_feature("Reset Missions (only)", "action", ROBBERY_RESETER.id, function()
    for i = 1, #LS_CONTRACT_MISSION_RST do
    menu.notify("Changes will only happen if you are outside your Auto-Shop\n\nMissions reseted","Heist Control", 3, 0x64F06414)
    stat_set_int(LS_CONTRACT_MISSION_RST[i][1], true, LS_CONTRACT_MISSION_RST[i][2])
    end
    end)
end

do
local LS_CONTRACT_RST = {
    {"TUNER_GEN_BS", 8371},
    {"TUNER_CURRENT", 0xFFFFFFF},
}
menu.add_feature("Reset Contracts", "action", ROBBERY_RESETER.id, function()
    for i = 1, #LS_CONTRACT_RST do
    menu.notify("Changes will only happen if you are outside your Auto-Shop\n\nContract reseted","Heist Control", 3, 0x64F06414)
    stat_set_int(LS_CONTRACT_RST[i][1], true, LS_CONTRACT_RST[i][2])
end
end)
end

do
local RST_COUNT_TNR = {
    {"TUNER_COUNT", 0},
    {"TUNER_EARNINGS", 0}
}
    menu.add_feature("Reset Total Gains & Completed Missions", "action", ROBBERY_RESETER.id, function()
    for i = 1, #RST_COUNT_TNR do
    menu.notify("It may only update if you are outside your workshop\n\nThe values have been reseted", "", 4, 0x64FF7878)
    stat_set_int(RST_COUNT_TNR[i][1], true, RST_COUNT_TNR[i][2])
    end
end)
end



-- Heist Cooldown Reminder
do
local COOLDOWN_REMIND = menu.add_feature("Heist Cooldown Reminder", "parent", mission_cheat.id)

menu.add_feature("Reminder for Cayo Perico Heist", "action", COOLDOWN_REMIND.id,function(HCR_Cayo)
    ui.notify_above_map("~h~~r~The timer will be started soon!\n\nRemember to activate only when you finish the Heist", "", 0) system.wait(60000)
    menu.notify("- Counting the next 16 minutes\n\n- You can play a different heist in the meantime :)\n\n- The cooldown for each Heist is individual", "(Cayo Perico Heist)", 15, 0x64FF78B4) system.wait(60000)
    system.wait(300000) menu.notify("- 5 minutes have passed\n\n- There are still 10 minutes left to finish the cooldown.\n\n- You will receive another notification soon", "(Cayo Perico Heist)", 10, 0x64FF78B4)
    system.wait(300000) menu.notify("- 10 minutes have passed\n\n- There are still 6 minutes left to finish the cooldown.\n\n- You will receive another notification soon", "(Cayo Perico Heist)", 10, 0x64FF78B4)
    system.wait(360000) menu.notify("- 16 minutes have passed\n\n- The cooldown is over!!!\n\n- Now you can play and get paid again\nEnjoy!", "(Cayo Perico Heist)", 20, 0x6400FF14) 
    return
    menu.notify("Heist Cooldown Reminder has been disabled...", "", 5, 0x64781EF0)
end)

menu.add_feature("Reminder for Diamond Casino Heist", "action", COOLDOWN_REMIND.id,function(HCR_Casino)
    ui.notify_above_map("~h~~r~The timer will be started soon!\n\nRemember to activate only when you finish the Heist", "", 0) system.wait(60000)
    menu.notify("- Counting the next 16 minutes\n\n- You can play a different heist in the meantime :)\n\n- The cooldown for each Heist is individual", "(Diamond Casino Heist)", 15, 0x64FF78B4) system.wait(60000)
    system.wait(300000) menu.notify("- 5 minutes have passed\n\n- There are still 10 minutes left to finish the cooldown.\n\n- You will receive another notification soon", "(Diamond Casino Heist)", 10, 0x64FF78B4)
    system.wait(300000) menu.notify("- 10 minutes have passed\n\n- There are still 6 minutes left to finish the cooldown.\n\n- You will receive another notification soon", "(Diamond Casino Heist)", 10, 0x64FF78B4)
    system.wait(360000) menu.notify("- 16 minutes have passed\n\n- The cooldown is over!!!\n\n- Now you can play and get paid again\nEnjoy!", "(Diamond Casino Heist)", 20, 0x6400FF14)
    return
    menu.notify("Heist Cooldown Reminder has been disabled...", "", 5, 0x64781EF0)
end)

menu.add_feature("Reminder for Doomsday Heist", "action", COOLDOWN_REMIND.id,function(HCR_Dooms)
    ui.notify_above_map("~h~~r~The timer will be started soon!\n\nRemember to activate only when you finish the Heist", "", 0) system.wait(60000)
    menu.notify("- Counting the next 16 minutes\n\n- You can play a different heist in the meantime :)\n\n- The cooldown for each Heist is individual", "(Doomsday Heist)", 15, 0x64FF78B4) system.wait(60000)
    system.wait(300000) menu.notify("- 5 minutes have passed\n\n- There are still 10 minutes left to finish the cooldown.\n\n- You will receive another notification soon", "(Doomsday Heist)", 10, 0x64FF78B4)
    system.wait(300000) menu.notify("- 10 minutes have passed\n\n- There are still 6 minutes left to finish the cooldown.\n\n- You will receive another notification soon", "(Doomsday Heist)", 10, 0x64FF78B4)
    system.wait(360000) menu.notify("- 16 minutes have passed\n\n- The cooldown is over!!!\n\nNow you can play and get paid again\nEnjoy!", "(Doomsday Heist)", 20, 0x6400FF14)
    return
    menu.notify("Heist Cooldown Reminder has been disabled...", "", 5, 0x64781EF0)
end)

menu.add_feature("Reminder for Classic Heists", "action", COOLDOWN_REMIND.id,function(HCR_Classic)
    ui.notify_above_map("~h~~r~The timer will be started soon!\n\nRemember to activate only when you finish the Heist", "", 0) system.wait(60000)
    menu.notify("- Counting the next 16 minutes\n\n- You can play a different heist in the meantime :)\n\n- The cooldown for each Heist is individual", "(Classic Heists)", 15, 0x64FF78B4) system.wait(60000)
    system.wait(300000) menu.notify("- 5 minutes have passed\n\n- There are still 10 minutes left to finish the cooldown.\n\n- You will receive another notification soon", "(Classic Heists)", 10, 0x64FF78B4)
    system.wait(300000) menu.notify("- 10 minutes have passed\n\n- There are still 6 minutes left to finish the cooldown.\n\n- You will receive another notification soon", "(Classic Heists)", 10, 0x64FF78B4)
    system.wait(360000) menu.notify("- 16 minutes have passed\n\n- The cooldown is over!!!\n\nNow you can play and get paid again\nEnjoy!", "(Classic Heists)", 20, 0x6400FF14)
    return 
    menu.notify("Heist Cooldown Reminder has been disabled...", "", 5, 0x64781EF0)
end)

menu.add_feature("Reminder for LS Robbery (Contracts)", "action", COOLDOWN_REMIND.id,function(HCR_LS)
    ui.notify_above_map("~h~~r~The timer will be started soon!\n\nRemember to activate only when you finish the Robbery.", "", 0) system.wait(60000)
    menu.notify("- Counting the next 17 minutes\n\n- You can play a different heist in the meantime :)\n\n- The cooldown for each Heist is individual", "(LS Robbery - Contracts)", 15, 0x64FF78B4) system.wait(60000)
    system.wait(300000) menu.notify("- 5 minutes have passed\n\n- There are still 10 minutes left to finish the cooldown.\n\n- You will receive another notification soon", "(LS Robbery- Contracts)", 10, 0x64FF78B4)
    system.wait(300000) menu.notify("- 10 minutes have passed\n\n- There are still 7 minutes left to finish the cooldown.\n\n- You will receive another notification soon", "(LS Robbery- Contracts)", 10, 0x64FF78B4)
    system.wait(420000) menu.notify("- 17 minutes have passed\n\n- The cooldown is over!!!\n\nNow you can play and get paid again\nEnjoy!", "(LS Robbery- Contracts)", 20, 0x6400FF14)
    return
    menu.notify("Heist Cooldown Reminder has been disabled...", "", 5, 0x64781EF0)
end)
end

do
menu.add_feature("Leave Session (Freeze game for a moment)", "action", mission_cheat.id, function()
    menu.notify("Task completed", "Heist Control", 3, 0x64FF78F0)
        local time = utils.time_ms() + 8500
        while time > utils.time_ms() do end
    end)
end




----------------------------抢劫-------------------------







