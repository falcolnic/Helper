script_name("Hospital Helper [3.0]")
script_description('Cross-platform helper for Medical Center (Hospital)')
script_author("Falcoln")
script_version("3.0")

require "lib.moonloader"
require 'encoding'.default = 'CP1251'
local u8 = require 'encoding'.UTF8

local function deepcopy(o, seen)
    seen = seen or {}
    if o == nil then return nil end
    if seen[o] then return seen[o] end

    local no
    if type(o) == 'table' then
        no = {}
        seen[o] = no

        for k, v in next, o, nil do
            no[deepcopy(k, seen)] = deepcopy(v, seen)
        end
        setmetatable(no, deepcopy(getmetatable(o), seen))
    else
        no = o
    end
    return no
end

local function deepmerge(a, b)
    for k, v in next, b, nil do
        if a[k] == nil then
            a[deepcopy(k)] = deepcopy(v)
        else
            if type(v) == 'table' and type(a[k]) == 'table' then
                deepmerge(a[k], v)
            end
        end
    end
end

local function load(default, filepath)

    local file = io.open(filepath, 'r')

    if file then
        local contents = file:read('*a')
        file:close()

        if #contents == 0 then
            return deepcopy(default)
        end

        local result, loaded = pcall(decodeJson, contents)

        if not result or not loaded then
            if not result then
                print('jsoncfg: failed to decode json, error:', loaded)
            end
            return deepcopy(default)
        end

        deepmerge(loaded, default)
        return loaded
    else
        return deepcopy(default)
    end
end

function save(data, filepath)
    local file, errstr = io.open(filepath, 'w')

    if file then
        local result, encoded = pcall(encodeJson, data)

        if result then
            file:write(encoded)
        else
            print('jsoncfg: failed to encode json, error:', encoded)
        end

        file:close()

        return result
    else
        print('jsoncfg: failed to open file, error:', errstr)
        return false
    end
end

local settings = {}

local default_settings = {

	general = {
		
		version = '3.0',
		
		expel_reason = '�.�.�.',
		
		accent_enable = true,
		anti_trivoga = false,
		heal_in_chat = false,
		auto_uval = false,
		rp_chat = true,
		
		moonmonet_theme_enable = true,
		moonmonet_theme_color = 16742777,
		
	},
	
	player_info = {
	
		name_surname = '',
		accent = '[����������� ������]:',
		fraction = '�� �������',
		fraction_tag = '����������',
		fraction_rank = '����������',
		fraction_rank_number = 0,
		sex = '����������',
	
	},
	
	price = {
		heal = 15000,
		heal_vc = 50,
		healbad = 300000,
		healactor = 300000,
		healactor_vc = 1000,
		medosm = 300000,
		ant = 25000,
		recept = 5000,
		tatu = 300000,
		med7 = 30000,
		med14 = 50000,
		med30 = 70000,
		med60 = 110000,
		mticket = 300000,
	},
	
	waiting = {
		my_wait = '1.500'
	},
	
	note = {
		my_note = ''
	},
	
	commands = {
	
		{ cmd = 'zd' , description = '���������� ������' , text = '�����������, � #my_ru_nick - #fraction_rank #fraction_tag.&��� � ���� ��� ������?', arg = '' , enable = true },
		
		{ cmd = 'go' , description = '������� ������ �� �����' , text = '������ #get_ru_nick(#arg_id), �������� �� ����.', arg = '#arg_id' , enable = true },
		
		{ cmd = 'cure' , description = '������� ������ �� ������' ,  text = '/todo ���-�� ��� ������ �����*��������� �������� ��� ��������&/cure #arg_id&/me ����������� ��� �������, ����� ����������� ����� �� ������ �������.&/do ����� �����������.&/me �������� ������ �������� �������� ������ ������, ����� �� ������� �������� �����.&/do ������ ��������� ����� ������ �������� �������� ������.&/do ������� ������ � ��������.&/todo �������*��������' , arg = '#arg_id' , enable = true },
		
		{ cmd = 'gd' , description = '���������� ����� (/godeath)' ,  text = '/me ������ �� ������� ���� ������� � ������� � ���� ������ #fraction_tag.&/me ������������� ���������� � �������� ��������� � ���������� ����� ����������� ������.&/godeath #arg_id' , arg = '#arg_id' , enable = true },
	
		{ cmd = 'hl' , description = '������� ������� �������' , text = '/me ������ �� ������ ���.����� ������ ��������� � ������� ��� �������� ��������.&/todo ���������� ��� ���������, ��� ��� �������*��������&/heal #arg_id #price_heal', arg = '#arg_id' , enable = true },
		
		{ cmd = 'hme' , description = '������� ������ ����' ,  text = '/me ������ �� ������ ���.����� ��������� � ��������� ���.&/heal #my_id #price_heal' , arg = '' , enable = true },
		
		{ cmd = 'hla' , description = '������� ��������� ������' ,  text = '/me ������ �� ������ ���.����� ��������� � ������� ��� �������� ��������.&/todo ������� ������ ��������� ��� ���������, ��� ��� �������*��������&/healactor #arg_id #price_actorheal' , arg = '#arg_id' , enable = true },
		
		{ cmd = 'hlb' , description = '������� ������ �� ����������������' ,  text = '/me ������ �� ������ ���.����� �������� �� ���������������� � ������� �� �������� ��������.&/todo ���������� ��� ��������, � � ������ ������� �� ���������� �� ����������������*��������&/healbad #arg_id' , arg = '#arg_id' , enable = true },
		
		{ cmd = 'medin' , description = '���������� ���.��������� ������' ,  text = '��� ���������� ���.��������� ��� ���������� �������� ����������� c����.&��������� ������� �� ����� �������� ������� ���.���������.&�� 1 ������ - $4��.���. �� 2 ������ - $8��.���. �� 3 ������ - $1.2��.���.&/me ������ �� ������ ���.����� ������ ����� ���.���������, ����� � ������ #fraction_tag.&/me ��������� ����� ���.��������� � �������� ��� ���������, ����� ������ ������ #fraction_tag.&� ���, �������, �� ����� ���� ��� �������� ���.���������?&/me �������� �������� ����� ���.��������� ������� ����� � ������ ������� � ���� ���.����.&/givemedinsurance #arg_id&/todo ��� ���� ���.���������, ������*���������� ����� � ���.���������� �������� �������� ����' , arg = '#arg_id' , enable = true },
		
		{ cmd = 'expel' , description = '������� ������ �� ��������' ,  text = '�� ������ �� ������ ����� ����������, � ������� ��� �� ��������!&/me ������� �������� ���� � ������ �� �������� � ��������� �� ��� �����.&/expel #arg_id #expel_reason' , arg = '#arg_id' , enable = true },
		
		{ cmd = 'unstuff' , description = '�������� ���������� � ������' ,  text = '������, ������ � ����� ���� ����������.&/do ������� ��� ��������� ���� ��������� � ������ �������.&/me ���������� ���� � ������ � ������ �� ���� ������� ��� ��������� ����.&/do ������� � ������ ����.&/me ����� ������� � ����� ����������� ��������&/me �������� ��������� �������� ����������� � ���� ��������.&/unstuff #arg_id #price_tatu&/me �������� ������� ��������� ���������� ��������� �������� � ������� ��� � ������.' , arg = '#arg_id' , enable = true },
		
		{ cmd = 'mt' , description = '���.������������ ��� �������� ������' ,  text = '������, ������ � ������� ��� ���.������������ ��� ��������� �������� ������&/me ������ �� ���.����� ���������� �������� � �������� �� �� ����.&/do �������� �� �����.&/todo ������ ���.������������*��������.&/mticket #arg_id #price_mticket&/n get_nick, ������� ����������� � /offer ��� ����������� ���.������������!' , arg = '#arg_id' , enable = true },

		{ cmd = 'pilot' , description = '���.������ ��� �������' ,  text = '������, ������ � ������� ��� ���.������ ��� �������.&/medcheck #arg_id #price_medosm&/n #get_nick(#arg_id), ������� ����������� � /offer ��� ����������� ���.�������!&/n ���� �� �� ������� �����������, �� �� ������ ������!&/me ������ �� ���.����� ���������� �������� � �������� �� �� ����.&/do �������� �� �����.&/todo ������ ���.������*��������.&������ � ������� ���� �����, �������� ��� � �������� ����.&/me ������ �� ���.����� ������� � ������� ��� ����������� ����� �������� ��������.&������, ������ ��������� ���, ������ � ������� ���� �����.&/me ��������� ������� �������� �� ����, �������� ������� � �����.&/do ������ ���� ������������ �������� ��������.&/todo �������*�������� ������� � ������ ��� � ���.����&����, ������ � ������� ���� ������������, ������� ������������ ������� ������!&/me ������ �� ���.����� ��������� � �������� ��� � ����� �������� ��������� ������������.&/do ������������ � ������ 65 ������ � ������.&/todo � ������������� � ��� ��� � �������*������ ��������� ������� � ���.����&/me ������� �� ����� ��� �������������� �������� � ����������� ��.&�� ���-� � ���� ��� �������, �� ��������� � ��� ��� � �������, �� ��������!' , arg = '#arg_id' , enable = true },
	
	},

	commands_manage = {
	
		{ cmd = 'inv' , description = '�������� ������ � �������' , text = '/do � ������� ������ ���� ������ � ������� �� ����������.&/me ������ �� ������ ���� ���� �� ������ ������ �� ����������.&/todo ��������, ��� ���� �� ����� ����������*��������� ���� �������� ��������&/invite #arg_id' , arg = '#arg_id', enable = true },
		
		{ cmd = 'uval' , description = '���������� ������ �� �������' , text = '/me ������ �� ������� ���� ������� � ������� � ���� ������ #fraction_tag.&/me �������� ���������� � ���������� � ������� ������� ������� � ������.&/uninvite #arg_id #arg2&/r ��������� #get_ru_nick(#arg_id) ��� ������ �� �������: #arg2' , arg = '#arg_id #arg2', enable = true },
		
		{ cmd = 'vig' , description = '������ �������� ������' , text = '/me ������ �� ������� ���� ������� � ������� � ���� ������ #fraction_tag.&/me �������� ���������� � ���������� � ������� ������� ������� � ������.&/fwarn #arg_id #arg2&/r ���������� #get_ru_nick(#arg_id) ����� �������! �������: #arg2' , arg = '#arg_id #arg2', enable = true },
		
		{ cmd = 'unvig' , description = '������ �������� ������' , text = '/me ������ �� ������� ���� ������� � ������� � ���� ������ #fraction_tag.&/me �������� ���������� � ���������� � ������� ������� ������� � ������.&/unfwarn #arg_id&/r ���������� #get_ru_nick(#arg_id) ��� ���� �������!' , arg = '#arg_id', enable = true },
		
		{ cmd = 'gr' , description = '���������/��������� ������' , text = '/me ������ �� ������� ���� ������� � ������� � ���� ������ #fraction_tag.&/me �������� ���������� � ���������� � ������� ������� ������� � ������.&/giverank #arg_id #arg2&/r ��������� #get_ru_nick(#arg_id) ������� ����� ���������!' , arg = '#arg_id #arg2', enable = true},
	
	},

}

local workingDirectory = getWorkingDirectory()
local configDirectory = workingDirectory .. "/config"
local path = configDirectory .. "/HospitalHelperSettings.json"

if not doesDirectoryExist(configDirectory) then
    createDirectory(configDirectory)
end

if doesFileExist(path) then
    settings = load(settings, path)
else
    settings = default_settings
    save(settings, path)
end

local reset_settings_bool = false

if tostring(settings.general.version) ~= tostring(thisScript().version) then
	settings = default_settings 
	save(settings, path)
	reset_settings_bool = true
	thisScript():reload()
end	

--------------------------------------------------------------------------------------------------------------

if MONET_DPI_SCALE == nil then MONET_DPI_SCALE = 1.0 end
function isMonetLoader() return MONET_VERSION ~= nil end

--------------------------------------------------------------------------------------------------------------
local sampev = require "samp.events"
local ffi = require 'ffi'
local imgui = require('mimgui')
local fa = require('fAwesome6_solid')
local monet = require('MoonMonet')

local sizeX, sizeY = getScreenResolution()
local new = imgui.new
local MainWindow = new.bool()
local checkbox_accent_enable = new.bool(settings.general.accent_enable)
local input_expel_reason = new.char[256](u8(settings.general.expel_reason))
local input_accent = new.char[256](u8(settings.player_info.accent))
local input_name_surname = new.char[256](u8(settings.player_info.name_surname))
local input_fraction_tag = new.char[256](u8(settings.player_info.fraction_tag))
local input_heal = new.char[256](u8(settings.price.heal))
local input_heal_vc = new.char[256](u8(settings.price.heal_vc))
local input_healbad = new.char[256](u8(settings.price.healbad))
local input_healactor = new.char[256](u8(settings.price.healactor))
local input_healactor_vc = new.char[256](u8(settings.price.healactor_vc))
local input_medosm = new.char[256](u8(settings.price.medosm))
local input_mticket = new.char[256](u8(settings.price.mticket))
local input_recept = new.char[256](u8(settings.price.recept))
local input_ant = new.char[256](u8(settings.price.ant))
local input_tatu = new.char[256](u8(settings.price.tatu))
local input_med7 = new.char[256](u8(settings.price.med7))
local input_med14 = new.char[256](u8(settings.price.med14))
local input_med30 = new.char[256](u8(settings.price.med30))
local input_med60 = new.char[256](u8(settings.price.med60))
local input_text_note_temp = settings.note.my_note:gsub('&', '\n')
local input_text_note = new.char[8192](u8(input_text_note_temp))
local slider = new.float(tonumber(settings.waiting.my_wait))
local theme = new.int()
if settings.general.moonmonet_theme_enable then theme[0] = 0 else theme[0] = 1 end

local BinderWindow = new.bool()
local ComboTags = new.int()
local item_list = {u8'��� ���������', u8'#arg (��������� ��� ������, �����/�����/�������)', u8'#arg_id (��������� ������ ID ������)', u8'#arg_id #arg2 (��������� 2 ���������: ID ������ � ������ ��� ������'}
local ImItems = imgui.new['const char*'][#item_list](item_list)
local change_cmd_bool = false
local change_cmd = ''
local change_description = ''
local change_text = ''
local change_arg = ''
local binder_create_command_9_10 = false

local MembersWindow = new.bool()
local members = {}
local members_new = {}
local members_check = false
local members_fraction = ''
local update_members_check = false

local MedCardMenu = new.bool()
local medcard_days = new.int()

local ReceptMenu = new.bool()
local recepts = new.int()

local AntibiotikMenu = new.bool()
local antibiotiks = new.int(1)

local FastMenu = new.bool()
local FastMenuButton = new.bool()
local FastMenuPlayers = new.bool()

local FastHealMenu = new.bool()
local heal_in_chat = false
local heal_in_chat_player_id = nil

local MedOsmotrMenu1, MedOsmotrMenu2, MedOsmotrMenu3, MedOsmotrMenu4, MedOsmotrMenu5 = new.bool(), new.bool(), new.bool(), new.bool(), new.bool()
local medosmtype = new.int()
local medcheck = false
local medcheck_no_medcard = false
local medcard_narko = 0
local medcard_status = ''

local message_color 
local message_color_hex 
if settings.general.moonmonet_theme_enable then
	function rgbToHex(rgb)
    local r = bit.band(bit.rshift(rgb, 16), 0xFF)
    local g = bit.band(bit.rshift(rgb, 8), 0xFF)
    local b = bit.band(rgb, 0xFF)
    
    local hex = string.format("%02X%02X%02X", r, g, b)
    return hex
end

	message_color = settings.general.moonmonet_theme_color
	message_color_hex = '{' ..  rgbToHex(settings.general.moonmonet_theme_color) .. '}'
else
	message_color_hex = '{FF7E7E}'
	message_color = 0xFF7E7E
end

local PlayerID = nil
local player_id = 0
local check_stats = false
local anti_flood_auto_uval = false
local spawncar_bool = false

local vc_vize_bool = false
local vc_vize_player_id = 0
local godeath_player_id = 0
local godeath_locate = ''
local godeath_city = ''

local tagReplacements = {

	my_id = function() return select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)) end,
    my_nick = function() return sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))) end,
	my_ru_nick = function() return TranslateNick(settings.player_info.name_surname) end,
	
	fraction_rank_number = function() return settings.player_info.fraction_rank_number end,
	fraction_rank = function() return settings.player_info.fraction_rank end,
	fraction_tag = function() return settings.player_info.fraction_tag end,
	fraction = function() return settings.player_info.fraction end,
	
	expel_reason = function() return settings.general.expel_reason end,
	
	price_heal = function()
		if u8(sampGetCurrentServerName()):find("Vice City") then
			return settings.price.heal_vc
		else
			return settings.price.heal
		end
	end,
	price_actorheal = function()
		if u8(sampGetCurrentServerName()):find("Vice City") then
			return settings.price.healactor_vc
		else
			return settings.price.healactor
		end
	end,
	price_medosm = function() return settings.price.medosm end,
	price_mticket = function() return settings.price.mticket end,
	price_ant = function() return settings.price.ant end,
	price_recept = function() return settings.price.recept end,
	price_tatu = function() return settings.price.tatu end,
	price_med7 = function() return settings.price.med7 end,
	price_med14 = function() return settings.price.med14 end,
	price_med30 = function() return settings.price.med30 end,
	price_med60 = function() return settings.price.med60 end,
	
	sex = function() 
		if settings.player_info.sex == '�������' then
			local temp = '�'
			return temp
		else
			local temp = ''
			return temp
		end
	end,
	
}

function main()

	if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(0) end 
	
	if not sampIsLocalPlayerSpawned() then 
		sampAddChatMessage('[Hospital Helper] {ffffff}������������� ������� ������ �������!',message_color)
		sampAddChatMessage('[Hospital Helper] {ffffff}��� ������ �������� ������� ������� ������������ (������� �� ������)',message_color)
		repeat wait(0) until sampIsLocalPlayerSpawned()
	end
	
	sampAddChatMessage('[Hospital Helper] {ffffff}�������� ������� ������ �������!', message_color)
	sampAddChatMessage('[Hospital Helper] {ffffff}���� ������� ���� ������� ' .. (isMonetLoader() and '������� ������� ' .. message_color_hex .. '/hh' or '������� ������� ' .. message_color_hex .. 'F2 {ffffff}��� ������� ������� ' .. message_color_hex .. '/hh'), message_color)
	
	if settings.player_info.name_surname == '' then
		settings.player_info.name_surname = TranslateNick(sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))))
		input_name_surname = new.char[256](u8(settings.player_info.name_surname))
		save(settings, path)
		check_stats = true
		sampSendChat('/stats')
	end

	sampRegisterChatCommand("hh", function() MainWindow[0] = not MainWindow[0]  end)
	
	sampRegisterChatCommand("i", function(id) fast_heal_in_chat(tonumber(id)) end)
	
	sampRegisterChatCommand("hm", show_fast_menu)
	sampRegisterChatCommand("mb", function() members_new = {} members_check = true sampSendChat("/members")  end)
	sampRegisterChatCommand("osm",medosm)
	sampRegisterChatCommand("spawncar",spawncar)
	sampRegisterChatCommand("vc",vc_vize)
	sampRegisterChatCommand("rec",recept)
	sampRegisterChatCommand("recept",recept)
	sampRegisterChatCommand("ant",antibiotik)
	sampRegisterChatCommand("antibiotik",antibiotik)
	sampRegisterChatCommand("mc",medcard)
	sampRegisterChatCommand("medcard",medcard)

	
	
	for _, command in ipairs(settings.commands) do
	
		if command.enable then
		
			sampRegisterChatCommand(command.cmd, function(arg)
				local arg_check = false
				local modifiedText = command.text
				
	
				if command.arg == '#arg' then
					if arg and arg ~= '' then
						modifiedText = modifiedText:gsub('#arg', arg or "")
						arg_check = true
					else
						sampAddChatMessage('[Hospital Helper] {ffffff}����������� ' .. message_color_hex .. '/' .. command.cmd .. ' [��������]', message_color)
						play_error_sound()
					end
				elseif command.arg == '#arg_id' then
					if arg and arg ~= '' and isParamID(arg) then
						arg = tonumber(arg)
						modifiedText = modifiedText:gsub('#get_nick%(#arg_id%)', sampGetPlayerNickname(arg) or "")
						modifiedText = modifiedText:gsub('#get_ru_nick%(#arg_id%)', TranslateNick(sampGetPlayerNickname(arg)) or "")
						modifiedText = modifiedText:gsub('#get_rp_nick%(#arg_id%)', sampGetPlayerNickname(arg):gsub('_',' ') or "")
						modifiedText = modifiedText:gsub('#arg_id', arg or "")
						arg_check = true
					else
						sampAddChatMessage('[Hospital Helper] {ffffff}����������� ' .. message_color_hex .. '/' .. command.cmd .. ' [ID ������]', message_color)
						play_error_sound()
					end
				elseif command.arg == '#arg_id #arg2' then
					if arg and arg ~= '' then
						local arg_id, arg2 = arg:match('(%d+) (.+)')
						if arg_id and arg2 and isParamID(arg_id) then
							arg_id = tonumber(arg_id)
							modifiedText = modifiedText:gsub('#get_nick%(#arg_id%)', sampGetPlayerNickname(arg_id) or "")
							modifiedText = modifiedText:gsub('#get_rp_nick%(#arg_id%)', sampGetPlayerNickname(arg_id):gsub('_',' ') or "")
							modifiedText = modifiedText:gsub('#get_ru_nick%(#arg_id%)', TranslateNick(sampGetPlayerNickname(arg_id)) or "")
							modifiedText = modifiedText:gsub('#arg_id', arg_id or "")
							modifiedText = modifiedText:gsub('#arg2', arg2 or "")
							arg_check = true
						else
							sampAddChatMessage('[Hospital Helper] {ffffff}����������� ' .. message_color_hex .. '/' .. command.cmd .. ' [ID ������] [��������]', message_color)
							play_error_sound()
						end
					else
						sampAddChatMessage('[Hospital Helper] {ffffff}����������� ' .. message_color_hex .. '/' .. command.cmd .. ' [ID ������] [��������]', message_color)
						play_error_sound()
					end
				elseif command.arg == '' then
					
					arg_check = true
				end

				if arg_check then
				
					lua_thread.create(function()
					
						local lines = {}

						for line in string.gmatch(modifiedText, "[^&]+") do
							table.insert(lines, line)
						end

						for _, line in ipairs(lines) do
						
							for tag, replacement in pairs(tagReplacements) do
								local success, result = pcall(string.gsub, line, "#" .. tag, replacement())
								if success then
									line = result
								else
									
								end
							end

							sampSendChat(line)
							
							wait(get_my_wait())
						end
						
					end)
				end
			end)
		end
	end
	
	for _, command in ipairs(settings.commands_manage) do
	
		if command.enable and tonumber(settings.player_info.fraction_rank_number) == 9 or tonumber(settings.player_info.fraction_rank_number) == 10 then
		
			sampRegisterChatCommand(command.cmd, function(arg)
				local arg_check = false
				local modifiedText = command.text
				
	
				if command.arg == '#arg' then
					if arg and arg ~= '' then
						modifiedText = modifiedText:gsub('#arg', arg or "")
						arg_check = true
					else
						sampAddChatMessage('[Hospital Helper] {ffffff}����������� ' .. message_color_hex .. '/' .. command.cmd .. ' [��������]', message_color)
						play_error_sound()
					end
				elseif command.arg == '#arg_id' then
					if arg and arg ~= '' and isParamID(arg) then
						arg = tonumber(arg)
						modifiedText = modifiedText:gsub('#get_nick%(#arg_id%)', sampGetPlayerNickname(arg) or "")
						modifiedText = modifiedText:gsub('#get_rp_nick%(#arg_id%)', sampGetPlayerNickname(arg):gsub('_',' ') or "")
						modifiedText = modifiedText:gsub('#get_ru_nick%(#arg_id%)', TranslateNick(sampGetPlayerNickname(arg)) or "")
						modifiedText = modifiedText:gsub('#arg_id', arg or "")
						arg_check = true
					else
						sampAddChatMessage('[Hospital Helper] {ffffff}����������� ' .. message_color_hex .. '/' .. command.cmd .. ' [ID ������]', message_color)
						play_error_sound()
					end
				elseif command.arg == '#arg_id #arg2' then
					if arg and arg ~= '' then
						local arg_id, arg2 = arg:match('(%d+) (.+)')
						if arg_id and arg2 and isParamID(arg_id) then
							arg_id = tonumber(arg_id)
							modifiedText = modifiedText:gsub('#get_nick%(#arg_id%)', sampGetPlayerNickname(arg_id) or "")
							modifiedText = modifiedText:gsub('#get_rp_nick%(#arg_id%)', sampGetPlayerNickname(arg_id):gsub('_',' ') or "")
							modifiedText = modifiedText:gsub('#get_ru_nick%(#arg_id%)', TranslateNick(sampGetPlayerNickname(arg_id)) or "")
							
							modifiedText = modifiedText:gsub('#arg_id', arg_id or "")
							modifiedText = modifiedText:gsub('#arg2', arg2 or "")
							arg_check = true
						else
							sampAddChatMessage('[Hospital Helper] {ffffff}����������� ' .. message_color_hex .. '/' .. command.cmd .. ' [ID ������] [��������]', message_color)
							play_error_sound()
						end
					else
						sampAddChatMessage('[Hospital Helper] {ffffff}����������� ' .. message_color_hex .. '/' .. command.cmd .. ' [ID ������] [��������]', message_color)
						play_error_sound()
					end
				elseif command.arg == '' then
					
					arg_check = true
				end

				if arg_check then
				
					lua_thread.create(function()
					
						local lines = {}

						for line in string.gmatch(modifiedText, "[^&]+") do
							table.insert(lines, line)
						end

						for _, line in ipairs(lines) do
						
							for tag, replacement in pairs(tagReplacements) do
								local success, result = pcall(string.gsub, line, "#" .. tag, replacement())
								if success then
									line = result
								else
									
								end
							end

							sampSendChat(line)
							
							wait(get_my_wait())
						end
						
					end)
				end
			end)
		end
	end

	while true do
		wait(0)
		
		if MembersWindow[0] and not update_members_check then
			update_members()
		end
		
		if isMonetLoader() and tonumber(#get_players()) > 0 and not FastMenu[0] and not FastMenuPlayers[0] then
			FastMenuButton[0] = true
		else
			FastMenuButton[0] = false
		end
		
		if not isMonetLoader() then
		
			if heal_in_chat and isKeyDown(VK_RETURN) and not sampIsDialogActive() and not sampIsChatInputActive() and not isPauseMenuActive() and not isSampfuncsConsoleActive() then
			    command("/heal #arg_id",heal_in_chat_player_id)
				heal_in_chat = false
				heal_in_chat_id = nil
			end
			
			if isKeyDown(VK_F2) and not MainWindow[0] then
				MainWindow[0] = true
			end
			
			if isKeyDown(VK_F3) then
				command("/heal #my_id", 0)
				wait(500)
			end
			
			local valid, ped = getCharPlayerIsTargeting(PLAYER_HANDLE)
			if valid and doesCharExist(ped) then
				local result, id = sampGetPlayerIdByCharHandle(ped)
				if result and id ~= -1 and isKeyJustPressed(VK_R) and isKeyJustPressed(VK_RBUTTON) then
					show_fast_menu(id)
				end
			end
		
		end
		
	end

end

function fast_heal_in_chat(id)

	id = tonumber(id)
	
	if sampIsPlayerConnected(id) then
		local _, ped = sampGetCharHandleBySampPlayerId(id)
		local nick = sampGetPlayerNickname(id)
		
		if _ then 
			local ppx, ppy, ppz = getCharCoordinates(PLAYER_PED)
			local localx, localy, localz = getCharCoordinates(ped)
			local x = tostring(localx):sub(1,9)
			local y = tostring(localy):sub(1,9)
			local z = tostring(localz):sub(1,4)
			if math.floor(getDistanceBetweenCoords3d(ppx, ppy, ppz, x, y, z)) > 4 and math.floor(getDistanceBetweenCoords3d(ppx, ppy, ppz, x, y, z)) <= 30 then
				sampAddChatMessage('[Hospital Helper] {ffffff}����� '..nick..' ������ �������� ���, �� �� ������� ������ �� ����!',message_color)
			elseif math.floor(getDistanceBetweenCoords3d(ppx, ppy, ppz, x, y, z)) <= 4 then
			
				if isMonetLoader() then
			
					sampAddChatMessage('[Hospital Helper] {ffffff}���� �������� ������ '..nick..', � ������� 5-�� ������ ������� ������',message_color)
					heal_in_chat_player_id = id
					lua_thread.create(function() 
						heal_in_chat = true
						FastHealMenu[0] = true
						wait(5000)
						FastHealMenu[0] = false
						heal_in_chat = false
					end)
			
				else
				
					sampAddChatMessage('[Hospital Helper] {ffffff}���� �������� ������ '..nick..', � ������� 5-�� ������ ������� ������y {00ccff}Enter',message_color)
					heal_in_chat_player_id = id
					lua_thread.create(function() 
						heal_in_chat = true
						wait(5000)
						heal_in_chat = false
					end)
			
				end
			end
		end
	end

end

function command (cmd,id)

	id = tonumber(id)

	for _, command in ipairs(settings.commands) do
		
			if command.text:find(cmd) then
					
				local modifiedText = command.text
					
				modifiedText = modifiedText:gsub('#get_nick%(#arg_id%)', sampGetPlayerNickname(id) or "")
				modifiedText = modifiedText:gsub('#get_rp_nick%(#arg_id%)', sampGetPlayerNickname(id):gsub('_','') or "")
				modifiedText = modifiedText:gsub('#get_ru_nick%(#arg_id%)', TranslateNick(sampGetPlayerNickname(id)) or "")
				modifiedText = modifiedText:gsub('#arg_id', id or "")
					
						lua_thread.create(function()
						
							local lines = {}

							for line in string.gmatch(modifiedText, "[^&]+") do
								table.insert(lines, line)
							end

							for _, line in ipairs(lines) do
							
								for tag, replacement in pairs(tagReplacements) do
									local success, result = pcall(string.gsub, line, "#" .. tag, replacement())
									if success then
										line = result
									else
										
									end
								end

								sampSendChat(line)
								
								wait(get_my_wait())
							end
							
						end)
			end
	end

end

function medosm(id)
	if isParamID(id) then
		lua_thread.create(function()
			player_id = tonumber(id)
			sampSendChat("������ � ������� ��� ���.������, ����� ��� ���� ���.����� ��� ��������.")
			medcheck = true
			MedOsmotrMenu2[0] = true
			wait(get_my_wait())
			sampSendChat("/n "..sampGetPlayerNickname(player_id)..", ������� /showmc "..select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)).." ���� �������� ��� ���.�����.")
		end)
	else
		sampAddChatMessage('[Hospital Helper] {ffffff}����������� ' .. message_color_hex .. '/osm [ID ������]',message_color)
		play_error_sound()
	end
end
function medcard(id)
	if isParamID(id) then
		lua_thread.create(function()
			sampSendChat("��� ���������� ���. ����� ��� ���������� �������� ������������ �����.")
			wait(get_my_wait())
			sampSendChat("��� ����� ������� �� ������ �������� ������� ��������.")
			wait(get_my_wait())
			sampSendChat("���. ����� �� 7 ���� - $"..settings.price.med7..", �� 14 ���� - $"..settings.price.med14..".")
			wait(get_my_wait())
			sampSendChat("���. ����� �� 30 ���� - $"..settings.price.med30..", �� 60 ���� - $"..settings.price.med60..".")
			wait(get_my_wait())
			sampSendChat("�������, �� ����� ���� ��� �������� ���. �����?")
			player_id = tonumber(id)
			MedCardMenu[0] = true
		end)
	else
		sampAddChatMessage('[Hospital Helper] {ffffff}����������� ' .. message_color_hex .. '/mc [ID] {ffffff}��� ' .. message_color_hex .. '/medcard [ID]',message_color)
		play_error_sound()
	end
end
function recept(id)
	if isParamID(id) then
		lua_thread.create(function()
			sampSendChat("������, ��������� ������ ������� ���������� $"..settings.price.recept..".")
			wait(get_my_wait())
			sampSendChat("������� ������� ��� ��������� ��������, ����� ���� �� ���������.")
			wait(get_my_wait())
			sampSendChat("/n ��������! � ������� ���� ������� �������� 5 ��������!")
			player_id = tonumber(id)
			ReceptMenu[0] = true
		end)
	else
		sampAddChatMessage('[Hospital Helper] {ffffff}����������� ' .. message_color_hex .. '/rec [ID] {ffffff}��� ' .. message_color_hex .. '/recept [ID]',message_color)
		play_error_sound()
	end
end
function antibiotik(id)
	if isParamID(id) then
		lua_thread.create(function()
			sampSendChat("������, c�������� ������ ����������� ���������� $"..settings.price.ant..".")
			wait(get_my_wait())
			sampSendChat("������� ������� ��� ��������� ������������, ����� ���� �� ���������.")
			wait(get_my_wait())
			sampSendChat("/n ��������! �� ������ ������ �� 1 �� 20 �����������!")
			player_id = tonumber(id)
			AntibiotikMenu[0] = true
		end)
	else
		sampAddChatMessage('[Hospital Helper] {ffffff}����������� ' .. message_color_hex.. '/ant [ID] {ffffff}��� ' .. message_color_hex .. '/antibiotik [ID]',message_color)
		play_error_sound()
	end
end

function update_members()
	lua_thread.create(function()
		update_members_check = true
		wait(1500)
		if MembersWindow[0] then
			members_new = {} 
			members_check = true 
			sampSendChat("/members") 
		end
		wait(1500)
		update_members_check = false
	end)
end

function spawncar()
	if tonumber(settings.player_info.fraction_rank_number) == 9 or tonumber(settings.player_info.fraction_rank_number) == 10 then 
		lua_thread.create(function()
			sampSendChat("/rb ��������! ����� 10 ������ ����� ����� ���������� ��������.")
			wait(2000)
			sampSendChat("/rb ������� ���������, ����� �� ����� ���������.")
			wait(8000)	
			spawncar_bool = true
			sampSendChat("/lmenu")
		end)
	else
		sampAddChatMessage('[Hospital Helper] {ffffff}��� ������� �������� ������ ������ � ������������!',message_color)
		play_error_sound()
	end
end
function vc_vize(id)
	if tonumber(settings.player_info.fraction_rank_number) == 9 or tonumber(settings.player_info.fraction_rank_number) == 10 then 
		if isParamID(id) then
			lua_thread.create(function()
				sampSendChat("/me ������ �� ������� ���� ������� � ������� � ���� ������ " .. settings.player_info.fraction_tag .. ".")
				wait(get_my_wait())
				sampSendChat("/me �������� ���������� � ���������� � ������� ������� ������� � ������")
				wait(get_my_wait())
				vc_vize_player_id = tonumber(id)
				vc_vize_bool = true
				sampSendChat("/lmenu")
			end)
		elseif id:find('^(%w+_%w+)') then
			lua_thread.create(function()
				sampSendChat("/me ������ �� ������� ���� ������� � ������� � ���� ������ " .. settings.player_info.fraction_tag .. ".")
				wait(get_my_wait())
				sampSendChat("/me �������� ���������� � ���������� � ������� ������� ������� � ������")
				wait(get_my_wait())
				if sampIsConnectedByNick(id) then
					vc_vize_player_id = tonumber(sampGetIDByNick(id))
					vc_vize_bool = true
					sampSendChat("/lmenu")
				else
					sampAddChatMessage('[Hospital Helper] {ffffff}������ � ����� ����� ������ ��� �� �������!',message_color)
				end
			end)
		else
			sampAddChatMessage('[Hospital Helper] {ffffff}����������� ' .. message_color_hex .. '/vc [ID] {ffffff}��� ' .. message_color_hex .. '/vc [Nick_Name]', message_color)
			play_error_sound()
		end

	else
		sampAddChatMessage('[Hospital Helper] {ffffff}��� ������� �������� ������ ������ � ������������!',message_color)
		play_error_sound()
	end
end

local world_heal_in_chat = { '��������', '������', '������', '���', '����', '���', '�����', 'heal ', 'hil', 'lek', 'lekni' }

function sampev.onServerMessage(color,text)
	
	--sampAddChatMessage('color = ' .. color .. ' , text = '..text,-1)
	

	
	if color == 766526463 and settings.general.auto_uval and not anti_flood_auto_uval and tonumber(settings.player_info.fraction_rank_number) == 9 or tonumber(settings.player_info.fraction_rank_number) == 10 then -- autouval

		if text:find("%[(.-)%] (.-) (.-)%[(.-)%]: (.+)") then -- /f /fb ��� /r /rb ��� ���� 
		
			lua_thread.create(function()
			
				local tag, rank, name, playerID, message = string.match(text, "%[(.-)%] (.+) (.-)%[(.-)%]: (.+)")
				
				if not message:find("], ����� �������� ���,") and not message:find("], ��������� (.+) +++ ����� �������� ���!") and not message:find("��������� (.+) ��� ������ �� ������� (.+)") and message:find("���") or message:find("���") or message:find("�������") or message:find("�������") or message:find("����") or message:find("����") then
					
					PlayerID = playerID
					
					anti_flood_auto_uval = true
					wait(10)
					
					if tag == "R" then
						sampSendChat("/rb "..name.."["..playerID.."], ��������� /rb +++ ����� �������� ���!")
					elseif tag == "F" then
						sampSendChat("/fb "..name.."["..playerID.."], ��������� /fb +++ ����� �������� ���!")
					end
					
					wait(5000)
					anti_flood_auto_uval = false
				
					
				end
				
				if message == "(( +++ ))" and PlayerID == playerID then
					wait(10)
					uninvite(PlayerID.." ���")
				end
				
			end)
	
		elseif text:find("%[(.-)%] %[(.-)%] (.+) (.-)%[(.-)%]: (.+)") then -- /r ��� /f � �����
		
			lua_thread.create(function()

				local tag, tag2, rank, name, playerID, message = string.match(text, "%[(.-)%] %[(.-)%] (.+) (.-)%[(.-)%]: (.+)")
				
				if not message:find("], ����� �������� ���,") and not message:find("], ��������� (.+) +++ ����� �������� ���!") and not message:find("��������� (.+) ��� ������ �� ������� (.+)") and message:find("���") or message:find("���") or message:find("�������") or message:find("�������") or message:find("����") or message:find("����") then
					
					PlayerID = playerID
					
					anti_flood_auto_uval = true
					wait(10)
					
					if tag == "R" then
						sampSendChat("/rb "..name.."["..playerID.."], ��������� /rb +++ ����� �������� ���!")
					elseif tag == "F" then
						sampSendChat("/fb "..name.."["..playerID.."], ��������� /fb +++ ����� �������� ���!")
					end
					
					wait(5000)
					anti_flood_auto_uval = false
					
				end 
				
				if message == "(( +++ ))" and PlayerID == playerID then
					wait(10)
					uninvite(PlayerID.." ���")
				end
					
			end)
		end
		
	end
	
	if text:find("{ffffff} ��� ��������� ����������� �� ������ (.+)") and medcheck then
		lua_thread.create(function()
			wait(10)
			sampSendChat("/offer")
		end)
	end
	
	if color == -1 and text:find(' �������:') and settings.general.heal_in_chat then
	
		
	
		local nick, id, message = text:match('(.+)%[(%d+)%] �������:{B7AFAF} (.+)')
		if nick and id and message then
			for _, keyword in ipairs(world_heal_in_chat) do
				if message:rupper() == (keyword:rupper()) then
					lua_thread.create(function()
						wait(10)
						fast_heal_in_chat(tonumber(id))
						
					end)
					break -- ���� ������� ����������, ������� �� �����
				end
			end
		end
	end
	
	if color == -253326081 and text:find('������') and settings.general.heal_in_chat then
		local nick, id, message = text:match('(.+)%[(%d+)%] ������: (.+)')
		if nick and id and message then
			for _, keyword in ipairs(world_heal_in_chat) do
				if message:rupper() == (keyword:rupper()) then
					lua_thread.create(function()
						wait(10)
						fast_heal_in_chat(tonumber(id))
						
					end)
					break -- ���� ������� ����������, ������� �� �����
				end
			end
		end
	end
	
	if text:find('�������� �������� � ������������ �������� � ������ (.+) %((.+)%).') then
		godeath_locate, godeath_city = text:match('�������� �������� � ������������ �������� � ������ (.+) %((.+)%).')
		return false
	end
	
	if text:find('%(%( ����� ������� �����, ������� /godeath (%d+). ������ �� ����� (.+) %)%)') then
		godeath_player_id = text:match('%(%( ����� ������� �����, ������� /godeath (%d+). ������ �� ����� (.+) %)%)')
		godeath_player_id = tonumber(godeath_player_id)
		
		local cmd = '/godeath'
		
		for _, command in ipairs(settings.commands) do
	
			if command.enable and command.text:find('/godeath ') then
				cmd =  '/' .. command.cmd
				
			end
		
		end
		
		sampAddChatMessage('[Hospital Helper] {ffffff}�� ������ ' .. message_color_hex .. godeath_city .. ' {ffffff}�������� ���������� ����� � ������������ �������� ' .. message_color_hex .. sampGetPlayerNickname(godeath_player_id), message_color)
		sampAddChatMessage('[Hospital Helper] {ffffff}����� ������� ���������� �����, ����������� ������� ' .. message_color_hex .. cmd .. ' '.. godeath_player_id, message_color)
		return false
	end
	
	if text:find("{FFFFFF}(.-) ������ ���� ����������� �������� � ��� � �����������.") then
		local PlayerName = text:match("{FFFFFF}(.-) ������ ���� ����������� �������� � ��� � �����������.")
		sampSendChat("/r "..TranslateNick(PlayerName).." - ��� ����� ���������!")
	end
	
end
function sampev.onSendChat(text)
	
	local ignore = {
		[")"] = true,
		["))"] = true,
		["("] = true,
		["(("] = true,
		["xD"] = true,
		["q"] = true,
		["(+)"] = true,
		["(-)"] = true,
		[":)"] = true,
		[":("] = true,
		["=)"] = true,
		[":p"] = true,
		[";p"] = true,
		["(rofl)"] = true,
		["XD"] = true,
		["(agr)"] = true,
		["O.o"] = true,
		[">.<"] = true,
		[">:("] = true,
		["<3"] = true,
	}
	if ignore[text] then
		return {text}
	end
	
	if settings.general.rp_chat then
		text = text:sub(1, 1):rupper()..text:sub(2, #text) 
		if not text:find('(.+)%.') and not text:find('(.+)%!') and not text:find('(.+)%?') then
			text = text .. '.'
		end
	end
	
	if settings.general.accent_enable then
		text = settings.player_info.accent .. ' ' .. text 
	end
	
	return {text}

end
function sampev.onSendCommand(text)

	if settings.general.rp_chat then
	
		local chats =  { '/vr', '/fam', '/al', '/s', '/b', '/n', '/r', '/rb', '/f', '/fb', '/j', '/jb', '/m' } 
	
		for _, cmd in ipairs(chats) do
		
			if text:find('^'.. cmd .. ' ') then
			
				local cmd_text = text:match('^'.. cmd .. ' (.+)')
				
				if cmd_text ~= nil then
				
					cmd_text = cmd_text:sub(1, 1):rupper()..cmd_text:sub(2, #cmd_text)
					
					text = cmd .. ' ' .. cmd_text
					
					if not text:find('(.+)%.') and not text:find('(.+)%!') and not text:find('(.+)%?') then
						text = text .. '.'
					end
				
				end
			end
			
			
		
		end
		
	end
	
	return {text}

end
function sampev.onShowDialog(dialogid, style, title, button1, button2, text)
	
	--sampAddChatMessage(dialogid,-1)

	if dialogid == 25685 and medcheck then -- medosm
		sampSendDialogResponse(25685, 1,0,0)
		return false
	end
	
	if dialogid == 25686 and medcheck then -- medosm
		sampSendDialogResponse(25686, 1,5,0)
		return false
	end
	
	if dialogid == 1234 and not text:find("�����������������") and medcheck then -- medcard
		
		medcard_narko = math.floor(text:match("{CEAD2A}����������������: (.+){FFFFFF}"))
		medcard_status = text:match("���. ����� %[(.+)%]\n")
		
		MedOsmotrMenu2[0] = false
		MedOsmotrMenu3[0] = true
		
		sampSendChat("/me ���� � ���� ���.����� � �������� ���������� �, ����� ������ ���.����� �������")
		
		sampSendDialogResponse(1234, 1,0,0)
		return false
		
	end

	if dialogid == 131 then -- /hme
		if text:find(sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))) then
			sampSendDialogResponse(131, 1,0,0)
			return false
		end
	end
	
	if dialogid == 15380 then -- ������ ���.�����
		if text:find("��������� ������") then
			sampAddChatMessage('[Hospital Helper] {ffffff}�������� ���� ����� ���������� ��������� ���. �����',message_color)
			sampSendDialogResponse(15380, 1,0,0)
			return false
		end
	end
	
	if dialogid == 25449 and settings.general.anti_trivoga then -- ��������� ������
		sampSendDialogResponse(25449, 0, 0, 0)
		return false
	end
	
	if dialogid == 235 and check_stats then -- ��������� ����������
	
		if text:find("{FFFFFF}���: {B83434}%[(.-)]") then
			settings.player_info.sex = text:match("{FFFFFF}���: {B83434}%[(.-)]")
		end
		
		if text:find("{FFFFFF}�����������: {B83434}%[(.-)]") then
			settings.player_info.fraction = text:match("{FFFFFF}�����������: {B83434}%[(.-)]")
			if settings.player_info.fraction == '�� �������' then
				sampAddChatMessage('[Hospital Helper] {ffffff}�� �� �������� � �����������!',message_color)
				settings.player_info.fraction_tag = "����������"
			else
				sampAddChatMessage('[Hospital Helper] {ffffff}���� ����������� ����������, ���: '..settings.player_info.fraction, message_color)
				
				if settings.player_info.fraction == '�������� ��' or settings.player_info.fraction == '�������� LS' then
					settings.player_info.fraction_tag = 'LSMC'
				elseif settings.player_info.fraction == '�������� ��' or settings.player_info.fraction == '�������� LV' then
					settings.player_info.fraction_tag = 'LVMC'
				elseif settings.player_info.fraction == '�������� ��' or settings.player_info.fraction == '�������� SF' then
					settings.player_info.fraction_tag = 'SFMC'
				elseif settings.player_info.fraction == '�������� Jefferson' or settings.player_info.fraction == '�������� ����������' then
					settings.player_info.fraction_tag = 'JMC'
				else
					settings.player_info.fraction_tag = 'Medical Center'
				end
				
				input_fraction_tag = new.char[256](u8(settings.player_info.fraction_tag))
				
				sampAddChatMessage('[Hospital Helper] {ffffff}����� ����������� �������� ��� '..settings.player_info.fraction_tag .. ". �� �� ������ �������� ��� � ����������", message_color)
				
			end
	
		end
		
		if text:find("{FFFFFF}���������: {B83434}(.+)%((%d+)%)") then
			settings.player_info.fraction_rank, settings.player_info.fraction_rank_number = text:match("{FFFFFF}���������: {B83434}(.+)%((%d+)%)(.+)������� �������")
			sampAddChatMessage('[Hospital Helper] {ffffff}���� ��������� ����������, ���: '..settings.player_info.fraction_rank.." ("..settings.player_info.fraction_rank_number..")", message_color)
		else
			settings.player_info.fraction_rank = "����������"
			settings.player_info.fraction_rank_number = 0
			sampAddChatMessage('[Hospital Helper] {ffffff}��������� ������, �� ���� �������� ��� ����!',message_color)
		end
		
		save(settings, path)
		sampSendDialogResponse(235, 0,0,0)
		check_stats = false
		return false
	end

	if dialogid == 1214 and spawncar_bool then -- ����� �/�
	
		sampSendDialogResponse(1214, 2, 3, 0)
		spawncar_bool = false
		return false 
		
	end
	
	if dialogid == 1214 and vc_vize_bool then -- VS Visa [0]
		sampSendDialogResponse(1214, 1, 8, 0)
		return false 
	end
	
	if dialogid == 25744 and vc_vize_bool then -- VS Visa [1]
		lua_thread.create(function()
			vc_vize_bool = false
			sampSendDialogResponse(25744, 1, 0, tostring(vc_vize_player_id))
			wait(get_my_wait())
			sampSendChat("/r ���������� "..TranslateNick(sampGetPlayerNickname(tonumber(vc_vize_player_id))).." ������ ���� ��� Vice City!")
		end)
		return false 
	end
	
	if dialogid == 25820 and vc_vize_bool then -- VS Visa [2]
		lua_thread.create(function()
			vc_vize_bool = false
			sampSendDialogResponse(25820, 1, 0, tostring(sampGetPlayerNickname(vc_vize_player_id)))
			wait(get_my_wait())
			sampSendChat("/r � ���������� "..TranslateNick(sampGetPlayerNickname(tonumber(vc_vize_player_id))).." ������ ���� ��� Vice City!")
		end)
		return false 
	end

	if dialogid == 26608 then --  arz fast menu
		sampSendDialogResponse(26608 , 0, 2, 0)
		return false 
	end

	if dialogid == 2015 and members_check then -- ������� 

        local count = 0
        local next_page = false
        local next_page_i = 0
		
		members_fraction = string.match(title, '(.+)%(� ����')
		members_fraction = string.gsub(members_fraction, '{(.+)}', '')
		

        for line in text:gmatch('[^\r\n]+') do

            count = count + 1

            if not line:find('���') and not line:find('��������') then

				local color, nickname, id, rank, rank_number, warns, afk = string.match(line, '{(.+)}(.+)%((%d+)%)\t(.+)%((%d+)%)\t(%d+) %((%d+)')
			
				if color ~= nil and nickname ~= nil and id ~= nil and rank ~= nil and rank_number ~= nil and warns ~= nil and afk ~= nil then
				
					local working = false

					if color:find('FF3B3B') then
						working = false
					elseif color:find('FFFFFF') then
						working = true
					end
				
					table.insert(members_new, { nick = nickname, id = id, rank = rank, rank_number = rank_number, warns = warns, afk = afk, working = working })
				
				end

            end

            if line:match('��������� ��������') then
                next_page = true
                next_page_i = count - 2
            end
        end
		
        if next_page then
            sampSendDialogResponse(dialogid, 1, next_page_i, 0)
            next_page = false
            next_pagei = 0
        else
            sampSendDialogResponse(dialogid, 0, 0, 0)
			
			members = members_new
			
			members_check = false
		  
			MembersWindow[0] = true
		  
        end

        return false

    end

end
function sampev.onCreate3DText(id, color, position, distance, testLOS, attachedPlayerId, attachedVehicleId, text)
   if text and text:find('��������� ������') and settings.general.anti_trivoga then -- �������� ��������� ������
		return false
	end
end

local russian_characters = {
    [168] = '�', [184] = '�', [192] = '�', [193] = '�', [194] = '�', [195] = '�', [196] = '�', [197] = '�', [198] = '�', [199] = '�', [200] = '�', [201] = '�', [202] = '�', [203] = '�', [204] = '�', [205] = '�', [206] = '�', [207] = '�', [208] = '�', [209] = '�', [210] = '�', [211] = '�', [212] = '�', [213] = '�', [214] = '�', [215] = '�', [216] = '�', [217] = '�', [218] = '�', [219] = '�', [220] = '�', [221] = '�', [222] = '�', [223] = '�', [224] = '�', [225] = '�', [226] = '�', [227] = '�', [228] = '�', [229] = '�', [230] = '�', [231] = '�', [232] = '�', [233] = '�', [234] = '�', [235] = '�', [236] = '�', [237] = '�', [238] = '�', [239] = '�', [240] = '�', [241] = '�', [242] = '�', [243] = '�', [244] = '�', [245] = '�', [246] = '�', [247] = '�', [248] = '�', [249] = '�', [250] = '�', [251] = '�', [252] = '�', [253] = '�', [254] = '�', [255] = '�',
}
function string.rlower(s)
    s = s:lower()
    local strlen = s:len()
    if strlen == 0 then return s end
    s = s:lower()
    local output = ''
    for i = 1, strlen do
        local ch = s:byte(i)
        if ch >= 192 and ch <= 223 then -- upper russian characters
            output = output .. russian_characters[ch + 32]
        elseif ch == 168 then -- �
            output = output .. russian_characters[184]
        else
            output = output .. string.char(ch)
        end
    end
    return output
end
function string.rupper(s)
    s = s:upper()
    local strlen = s:len()
    if strlen == 0 then return s end
    s = s:upper()
    local output = ''
    for i = 1, strlen do
        local ch = s:byte(i)
        if ch >= 224 and ch <= 255 then -- lower russian characters
            output = output .. russian_characters[ch - 32]
        elseif ch == 184 then -- �
            output = output .. russian_characters[168]
        else
            output = output .. string.char(ch)
        end
    end
    return output
end
function TranslateNick(name)
	if name:match('%a+') then
        for k, v in pairs({['ph'] = '�',['Ph'] = '�',['Ch'] = '�',['ch'] = '�',['Th'] = '�',['th'] = '�',['Sh'] = '�',['sh'] = '�', ['ea'] = '�',['Ae'] = '�',['ae'] = '�',['size'] = '����',['Jj'] = '��������',['Whi'] = '���',['lack'] = '���',['whi'] = '���',['Ck'] = '�',['ck'] = '�',['Kh'] = '�',['kh'] = '�',['hn'] = '�',['Hen'] = '���',['Zh'] = '�',['zh'] = '�',['Yu'] = '�',['yu'] = '�',['Yo'] = '�',['yo'] = '�',['Cz'] = '�',['cz'] = '�', ['ia'] = '�', ['ea'] = '�',['Ya'] = '�', ['ya'] = '�', ['ove'] = '��',['ay'] = '��', ['rise'] = '����',['oo'] = '�', ['Oo'] = '�', ['Ee'] = '�', ['ee'] = '�', ['Un'] = '��', ['un'] = '��', ['Ci'] = '��', ['ci'] = '��', ['yse'] = '��', ['cate'] = '����', ['eow'] = '��', ['rown'] = '����', ['yev'] = '���', ['Babe'] = '�����', ['Jason'] = '�������', ['liy'] = '���', ['ane'] = '���', ['ame'] = '���'}) do
            name = name:gsub(k, v) 
        end
		for k, v in pairs({['B'] = '�',['Z'] = '�',['T'] = '�',['Y'] = '�',['P'] = '�',['J'] = '��',['X'] = '��',['G'] = '�',['V'] = '�',['H'] = '�',['N'] = '�',['E'] = '�',['I'] = '�',['D'] = '�',['O'] = '�',['K'] = '�',['F'] = '�',['y`'] = '�',['e`'] = '�',['A'] = '�',['C'] = '�',['L'] = '�',['M'] = '�',['W'] = '�',['Q'] = '�',['U'] = '�',['R'] = '�',['S'] = '�',['zm'] = '���',['h'] = '�',['q'] = '�',['y'] = '�',['a'] = '�',['w'] = '�',['b'] = '�',['v'] = '�',['g'] = '�',['d'] = '�',['e'] = '�',['z'] = '�',['i'] = '�',['j'] = '�',['k'] = '�',['l'] = '�',['m'] = '�',['n'] = '�',['o'] = '�',['p'] = '�',['r'] = '�',['s'] = '�',['t'] = '�',['u'] = '�',['f'] = '�',['x'] = 'x',['c'] = '�',['``'] = '�',['`'] = '�',['_'] = ' '}) do
            name = name:gsub(k, v) 
        end
        return name
    end
	return name
end
function isParamID(id)
	
	if id ~= nil and tostring(id):find('%d') and not tostring(id):find('%D') and string.len(id) >= 1 and string.len(id) <= 3 then
		return true
	else
		return false
	end

end
function get_my_wait()
	return settings.waiting.my_wait * 1000
	
end
function play_error_sound()
	if not isMonetLoader() then
		if sampIsLocalPlayerSpawned() then
			addOneOffSound(getCharCoordinates(PLAYER_PED),1149)
		end
	end
end
function show_fast_menu(id)
	
	if isParamID(id) then 
		player_id = tonumber(id)
		FastMenu[0] = true
	else
		if isMonetLoader() then 
			if not FastMenuPlayers[0] then
				sampAddChatMessage('[Hospital Helper] {ffffff}����������� {00ccff}/hm [ID]',message_color)
			end
		else
			sampAddChatMessage('[Hospital Helper] {ffffff}����������� {00ccff}/hm [ID] {ffffff}��� ���������� �� ������ ����� {00ccff}��� + R',message_color) 
		end 
	end 
	
end
function get_players()
	
	local myPlayerId = sampGetPlayerIdByCharHandle(PLAYER_PED)
	local myX, myY, myZ = getCharCoordinates(PLAYER_PED)
	
	local playersInRange = {}
	
	for _, h in pairs(getAllChars()) do
		__, id = sampGetPlayerIdByCharHandle(h)
		___, m = sampGetPlayerIdByCharHandle(PLAYER_PED)
		
		id = tonumber(id)
		
		if id ~= -1 and id ~= m and doesCharExist(h) then
			local x, y, z = getCharCoordinates(h)
			local mx, my, mz = getCharCoordinates(PLAYER_PED)
			local dist = getDistanceBetweenCoords3d(mx, my, mz, x, y, z)
			if dist <= 5 then
				table.insert(playersInRange, id)
			end
		end
		
		
		
	end
	
	return playersInRange
		
end
function sampIsConnectedByNick(nick_arg)
	local result = false
	for i = 0, sampGetMaxPlayerId() do
		if sampIsPlayerConnected(tonumber(i)) then
			local rnick = sampGetPlayerNickname(tonumber(i))
			if rnick == nick_arg then
				result = true
			end
		end
	end
	return result
end
function sampGetIDByNick(nick_arg)
	for i = 0, sampGetMaxPlayerId() do
		if sampIsPlayerConnected(tonumber(i)) then
			local rnick = sampGetPlayerNickname(tonumber(i))
			if rnick == nick_arg then
				return tonumber(i)
			end
		end
	end
end

imgui.OnInitialize(function()
	imgui.GetIO().IniFilename = nil
	fa.Init(14 * MONET_DPI_SCALE)

	local tmp = imgui.ColorConvertU32ToFloat4(settings.general.moonmonet_theme_color)
	mmcolor = new.float[3](tmp.z, tmp.y, tmp.x)
	gen_color = monet.buildColors(settings.general.moonmonet_theme_color, 1.0, true)
	

	if settings.general.moonmonet_theme_enable then
		apply_moonmonet_theme()
	else 
		apply_dark_theme()
	end
	
end)

local MainWindow = imgui.OnFrame(
    function() return MainWindow[0] end,
    function(player)
	
		imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(600 * MONET_DPI_SCALE, 425	* MONET_DPI_SCALE), imgui.Cond.FirstUseEver)
		imgui.Begin(fa.HOSPITAL.." Hospital Helper##main", MainWindow, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove )
		
		if imgui.BeginTabBar('Tabs') then
		
			if imgui.BeginTabItem(fa.HOUSE..u8' ������� ����') then
			
				
				if imgui.BeginChild('##1', imgui.ImVec2(589 * MONET_DPI_SCALE, 172 * MONET_DPI_SCALE), true) then
				
					imgui.CenterText(fa.USER_DOCTOR .. u8' ���������� ��� ����������')
					imgui.Separator()
					imgui.Columns(3)
					imgui.CenterColumnText(u8"��� � �������:")
					imgui.SetColumnWidth(-1, 230 * MONET_DPI_SCALE)
					imgui.NextColumn()
					imgui.CenterColumnText(u8(settings.player_info.name_surname))
					imgui.SetColumnWidth(-1, 250 * MONET_DPI_SCALE)
					imgui.NextColumn()
					if imgui.CenterColumnSmallButton(u8'��������##name_surname') then
						settings.player_info.name_surname = TranslateNick(sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))))
						input_name_surname = new.char[256](u8(settings.player_info.name_surname))
						save(settings, path)
						imgui.OpenPopup(fa.USER_DOCTOR .. u8' ��� � �������##name_surname')
					end
					if imgui.BeginPopupModal(fa.USER_DOCTOR .. u8' ��� � �������##name_surname', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove ) then
						imgui.PushItemWidth(200 * MONET_DPI_SCALE)
						imgui.InputText(u8'##name_surname', input_name_surname, 256) 
						if imgui.Button(u8'���������', imgui.ImVec2(200 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
							settings.player_info.name_surname = u8:decode(ffi.string(input_name_surname))
							save(settings, path)
							imgui.CloseCurrentPopup()
						end
						imgui.End()
					end
					
					imgui.SetColumnWidth(-1, 100 * MONET_DPI_SCALE)
					
					imgui.Columns(1)
					
					imgui.Separator()
					
					imgui.Columns(3)
					imgui.CenterColumnText(u8"���:")
					imgui.NextColumn()
					imgui.CenterColumnText(u8(settings.player_info.sex))
					imgui.NextColumn()
					if imgui.CenterColumnSmallButton(u8'��������##sex') then
					
						
						if settings.player_info.sex == '����������' then
							check_stats = true
							sampSendChat('/stats')
						elseif settings.player_info.sex == '�������' then
							settings.player_info.sex = '�������'
							save(settings, path)
						elseif settings.player_info.sex == '�������' then
							settings.player_info.sex = '�������'
							save(settings, path)
						end
						
						
					end
					imgui.Columns(1)
					
					imgui.Separator()
					
					imgui.Columns(3)
					imgui.CenterColumnText(u8"������:")
					imgui.NextColumn()
					if checkbox_accent_enable[0] then
						imgui.CenterColumnText(u8(settings.player_info.accent))
					else 
						imgui.CenterColumnText(u8'���������')
					end
					imgui.NextColumn()
					if imgui.CenterColumnSmallButton(u8'��������##accent') then
						imgui.OpenPopup(fa.USER_DOCTOR .. u8' ������ ���������##accent')
					end
					if imgui.BeginPopupModal(fa.USER_DOCTOR .. u8' ������ ���������##accent', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove ) then
						
						if imgui.Checkbox('##checkbox_accent_enable', checkbox_accent_enable) then
							settings.general.accent_enable = checkbox_accent_enable[0]
							save(settings, path)
						end
						
						imgui.SameLine()
						
						imgui.PushItemWidth(170 * MONET_DPI_SCALE)
						imgui.InputText(u8'##accent_input', input_accent, 256) 
						
						imgui.Separator()
						if imgui.Button(u8'���������', imgui.ImVec2(200 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then 
							settings.player_info.accent = u8:decode(ffi.string(input_accent))
							save(settings, path)
							imgui.CloseCurrentPopup()
						end
						imgui.End()
					end
					imgui.Columns(1)
					
					imgui.Separator()
					

					
					imgui.Columns(3)
					imgui.CenterColumnText(u8"�����������:")
					imgui.NextColumn()
					imgui.CenterColumnText(u8(settings.player_info.fraction))
					imgui.NextColumn()
					
					if imgui.CenterColumnSmallButton(u8'��������##fraction') then
						check_stats = true
						sampSendChat('/stats')
					end
					
					imgui.Columns(1)
					
					imgui.Separator()
					
					imgui.Columns(3)
					imgui.CenterColumnText(u8"��� �����������:")
					imgui.NextColumn()
					imgui.CenterColumnText(u8(settings.player_info.fraction_tag))
					imgui.NextColumn()
					if imgui.CenterColumnSmallButton(u8'��������##fraction_tag') then
						imgui.OpenPopup(fa.USER_DOCTOR .. u8' ��� �����������##fraction_tag')
					end
					if imgui.BeginPopupModal(fa.USER_DOCTOR .. u8' ��� �����������##fraction_tag', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove ) then
						imgui.PushItemWidth(200 * MONET_DPI_SCALE)
						imgui.InputText(u8'##input_fraction_tag', input_fraction_tag, 256)
						imgui.Separator()
						if imgui.Button(u8'���������', imgui.ImVec2(200 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
							settings.player_info.fraction_tag = u8:decode(ffi.string(input_fraction_tag))
							save(settings, path)
							imgui.CloseCurrentPopup()
						end
						imgui.End()
					end
					imgui.Columns(1)
					
					imgui.Separator()
					
					imgui.Columns(3)
					imgui.CenterColumnText(u8"��������� � �����������:")
					imgui.NextColumn()
					imgui.CenterColumnText(u8(settings.player_info.fraction_rank) .. " (" .. settings.player_info.fraction_rank_number .. ")")
					imgui.NextColumn()
					if imgui.CenterColumnSmallButton(u8"��������##rank") then
						check_stats = true
						sampSendChat('/stats')
					end
					imgui.Columns(1)
				
				imgui.EndChild()
				end
				
				if imgui.BeginChild('##2', imgui.ImVec2(589 * MONET_DPI_SCALE, 53 * MONET_DPI_SCALE), true) then
				
					imgui.CenterText(fa.CIRCLE_INFO .. u8' �������������� ����������')
					imgui.Separator()
				
					imgui.Columns(3)
					imgui.CenterColumnText(u8"������� ������ ��� /expel:")
					imgui.SetColumnWidth(-1, 230 * MONET_DPI_SCALE)
					imgui.NextColumn()
					imgui.CenterColumnText(u8(settings.general.expel_reason))
					imgui.SetColumnWidth(-1, 250 * MONET_DPI_SCALE)
					imgui.NextColumn()
					if imgui.CenterColumnSmallButton(u8'��������##expel_reason') then
						imgui.OpenPopup(fa.DOOR_OPEN .. u8' �������� ������� ��� ������##expel_reason')
					end
					if imgui.BeginPopupModal(fa.DOOR_OPEN .. u8' �������� ������� ��� ������##expel_reason', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove ) then
						imgui.PushItemWidth(200 * MONET_DPI_SCALE)
						imgui.InputText(u8'##expel_reason', input_expel_reason, 256) 
						if imgui.Button(u8'���������', imgui.ImVec2(200 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
							settings.general.expel_reason = u8:decode(ffi.string(input_expel_reason))
							save(settings, path)
							imgui.CloseCurrentPopup()
						end
						imgui.End()
					end
					imgui.SetColumnWidth(-1, 100 * MONET_DPI_SCALE)
					
					imgui.Columns(1)
					
					
					
					
					
					
				
				
				imgui.EndChild()
				end
				
				if imgui.BeginChild('##3', imgui.ImVec2(589 * MONET_DPI_SCALE, 125 * MONET_DPI_SCALE), true) then
				
					imgui.CenterText(fa.SITEMAP .. u8' �������������� �������')
					imgui.Separator()
					

					imgui.Columns(3)
					imgui.CenterColumnText(u8"���� ��������� ������")
					imgui.SameLine(nil, 5) imgui.TextDisabled("[?]")
					if imgui.IsItemHovered() then
						imgui.SetTooltip(u8"������� ��������� ������ ������� ��������� �� ������� �� 1 �����\n��� ����� �� �� ������ �������� �������� �� ��-�� ���� ������")
					end
					imgui.SetColumnWidth(-1, 230 * MONET_DPI_SCALE)
					imgui.NextColumn()
					if settings.general.anti_trivoga then
						imgui.CenterColumnText(u8'��������')
					else
						imgui.CenterColumnText(u8'���������')
					end
					imgui.SetColumnWidth(-1, 250 * MONET_DPI_SCALE)
					imgui.NextColumn()
					if imgui.CenterColumnSmallButton(u8'��������##anti_trivoga') then
						settings.general.anti_trivoga = not settings.general.anti_trivoga
						save(settings, path)
					end
					imgui.SetColumnWidth(-1, 100 * MONET_DPI_SCALE)
					
					imgui.Columns(1)
					
					imgui.Separator()
					
					imgui.Columns(3)
					imgui.CenterColumnText(u8"��� �� ����")
					imgui.SameLine(nil, 5) imgui.TextDisabled("[?]")
					if imgui.IsItemHovered() then
						imgui.SetTooltip(u8"��������� �������� ����� ������ ������ ������ ��������� ������� ������ ���� �� ��������")
					end
					imgui.NextColumn()
					if settings.general.heal_in_chat then
						imgui.CenterColumnText(u8'��������')
					else
						imgui.CenterColumnText(u8'���������')
					end
					imgui.NextColumn()
					if imgui.CenterColumnSmallButton(u8'��������##healinchat') then
						settings.general.heal_in_chat = not settings.general.heal_in_chat
						save(settings, path)
					end
					
					imgui.Columns(1)
					
					imgui.Separator()
					
					imgui.Columns(3)
					imgui.CenterColumnText(u8"RP �������")
					imgui.SameLine(nil, 5) imgui.TextDisabled("[?]")
					if imgui.IsItemHovered() then
						imgui.SetTooltip(u8"��� ���� ��������� � ��� ������������� ����� � ��������� ����� � � ������ � �����")
					end
					imgui.NextColumn()
					if settings.general.rp_chat then
						imgui.CenterColumnText(u8'��������')
					else
						imgui.CenterColumnText(u8'���������')
					end
					imgui.NextColumn()
					if imgui.CenterColumnSmallButton(u8'��������##rp_chat') then
						settings.general.rp_chat = not settings.general.rp_chat
						save(settings, path)
					end
					
					imgui.Columns(1)
					
					imgui.Separator()
					
					imgui.Columns(3)
					imgui.CenterColumnText(u8"���� ����")
					imgui.SameLine(nil, 5) imgui.TextDisabled("[?]")
					if imgui.IsItemHovered() then
						imgui.SetTooltip(u8"�������������� ���������� �����������, ������� ����� ���� ���\n������� �������� ������ ���� �� 9/10 ����!")
					end
					imgui.NextColumn()
					if settings.general.auto_uval then
						imgui.CenterColumnText(u8'��������')
					else
						imgui.CenterColumnText(u8'���������')
					end
					imgui.NextColumn()
					if imgui.CenterColumnSmallButton(u8'��������##autouval') then
						if tonumber(settings.player_info.fraction_rank_number) == 9 or tonumber(settings.player_info.fraction_rank_number) == 10 then 
							settings.general.auto_uval = not settings.general.auto_uval
						else
							settings.general.auto_uval = false
							sampAddChatMessage('[Hospital Helper] {ffffff}��� ������� �������� ������ ������ � ������������!',message_color)
						end
						save(settings, path)
					end
					
					
				
				imgui.EndChild()
				end
	
				imgui.EndTabItem()
			end
			
			if imgui.BeginTabItem(fa.RECTANGLE_LIST..u8' ������� � ���������') then 
				
				if imgui.BeginTabBar('Tabs2') then
				
					if imgui.BeginTabItem(fa.BARS..u8' ����� ������� ��� ���� ������ ') then 
							
						if imgui.BeginChild('##1', imgui.ImVec2(589 * MONET_DPI_SCALE, 333 * MONET_DPI_SCALE), true) then
				
							imgui.Columns(3)
							imgui.CenterColumnText(u8"�������")
							imgui.SetColumnWidth(-1, 170 * MONET_DPI_SCALE)
							imgui.NextColumn()
							imgui.CenterColumnText(u8"��������")
							imgui.SetColumnWidth(-1, 300 * MONET_DPI_SCALE)
							imgui.NextColumn()
							imgui.CenterColumnText(u8"��������")
							imgui.SetColumnWidth(-1, 150 * MONET_DPI_SCALE)
							imgui.Columns(1)
							
							imgui.Separator()
							
							imgui.Columns(3)
							imgui.CenterColumnText(u8"/hh")
							imgui.NextColumn()
							imgui.CenterColumnText(u8"������� ������� ���� �������")
							imgui.NextColumn()
							imgui.CenterColumnText(u8"����������")
							imgui.Columns(1)
					
							imgui.Separator()
							
							imgui.Columns(3)
							imgui.CenterColumnText(u8"/hm")
							imgui.NextColumn()
							imgui.CenterColumnText(u8"������� ������� ���� ��������������")
							imgui.NextColumn()
							imgui.CenterColumnText(u8"����������")
							imgui.Columns(1)
							
							imgui.Separator()
							
							imgui.Columns(3)
							imgui.CenterColumnText(u8"/mb")
							imgui.NextColumn()
							imgui.CenterColumnText(u8"������� ������ ����������� � ����")
							imgui.NextColumn()
							imgui.CenterColumnText(u8"����������")
							imgui.Columns(1)
							
							imgui.Separator()
							
							imgui.Columns(3)
							imgui.CenterColumnText(u8"/m�")
							imgui.NextColumn()
							imgui.CenterColumnText(u8"������ ������ ���.�����")
							imgui.NextColumn()
							imgui.CenterColumnText(u8"����������")
							imgui.Columns(1)
							
							imgui.Separator()
							
							imgui.Columns(3)
							imgui.CenterColumnText(u8"/ant")
							imgui.NextColumn()
							imgui.CenterColumnText(u8"������ ������ �����������")
							imgui.NextColumn()
							imgui.CenterColumnText(u8"����������")
							imgui.Columns(1)
							
							imgui.Separator()
							
							imgui.Columns(3)
							imgui.CenterColumnText(u8"/rec")
							imgui.NextColumn()
							imgui.CenterColumnText(u8"������ ������ �������")
							imgui.NextColumn()
							imgui.CenterColumnText(u8"����������")
							imgui.Columns(1)
							
							imgui.Separator()
							
							imgui.Columns(3)
							imgui.CenterColumnText(u8"/osm")
							imgui.NextColumn()
							imgui.CenterColumnText(u8"�������� ������ ���.������ ������")
							imgui.NextColumn()
							imgui.CenterColumnText(u8"����������")
							imgui.Columns(1)
							
							imgui.Separator()
							
							for _, command in ipairs(settings.commands) do
							
								imgui.Columns(3)
								
								if command.enable then
									imgui.CenterColumnText('/' .. u8(command.cmd))
									imgui.NextColumn()
									imgui.CenterColumnText(u8(command.description))
									imgui.NextColumn()
								else
									imgui.CenterColumnTextDisabled('/' .. u8(command.cmd))
									imgui.NextColumn()
									imgui.CenterColumnTextDisabled(u8(command.description))
									imgui.NextColumn()
								end
								
								imgui.Text('    ')
								
								imgui.SameLine()
								
								
								if command.enable then
									if imgui.SmallButton(fa.TOGGLE_ON .. '##'..command.cmd) then
										command.enable = not command.enable
										save(settings, path)
										sampUnregisterChatCommand(command.cmd)
									end
									if imgui.IsItemHovered() then
										imgui.SetTooltip(u8"���������� ������� /"..command.cmd)
									end
								else
									if imgui.SmallButton(fa.TOGGLE_OFF .. '##'..command.cmd) then
										command.enable = not command.enable
										save(settings, path)
										sampRegisterChatCommand(command.cmd, function(arg)
							
											local arg_check = false
											
											local modifiedText = command.text

											if command.arg == '#arg' then
												if arg and arg ~= '' then
													modifiedText = modifiedText:gsub('#arg', arg or "")
													arg_check = true
												else
													sampAddChatMessage('[Hospital Helper] {ffffff}����������� ' .. message_color_hex .. '/' .. command.cmd .. ' [��������]', message_color)
												end
											elseif command.arg == '#arg_id' then
												if arg and arg ~= '' and isParamID(arg) then
											
													
													modifiedText = modifiedText:gsub('#get_nick%(#arg_id%)', sampGetPlayerNickname(arg) or "")
													modifiedText = modifiedText:gsub('#get_ru_nick%(#arg_id%)', TranslateNick(sampGetPlayerNickname(arg)) or "")
													modifiedText = modifiedText:gsub('#get_rp_nick%(#arg_id%)', sampGetPlayerNickname(arg):gsub('_',' ') or "")
													modifiedText = modifiedText:gsub('#arg_id', arg or "")
													
													arg_check = true
												else
													sampAddChatMessage('[Hospital Helper] {ffffff}����������� ' .. message_color_hex .. '/' .. command.cmd .. ' [ID ������]', message_color)
												end
											elseif command.arg == '#arg_id #arg2' then
												if arg and arg ~= '' then
													local arg_id, arg2 = arg:match('(%d+) (.+)')
													if arg_id and arg2 and isParamID(arg_id) then
													
													
														modifiedText = modifiedText:gsub('#get_nick%(#arg_id%)', sampGetPlayerNickname(arg_id) or "")
														modifiedText = modifiedText:gsub('#get_ru_nick%(#arg_id%)', TranslateNick(sampGetPlayerNickname(arg_id)) or "")
														modifiedText = modifiedText:gsub('#get_rp_nick%(#arg_id%)', sampGetPlayerNickname(arg_id):gsub('_',' ') or "")
														modifiedText = modifiedText:gsub('#arg_id', arg or "")
																		
														modifiedText = modifiedText:gsub('#arg_id', arg_id or "")
														modifiedText = modifiedText:gsub('#arg2', arg2 or "")
														arg_check = true
													else
														sampAddChatMessage('[Hospital Helper] {ffffff}����������� ' .. message_color_hex .. '/' .. command.cmd .. ' [ID ������] [��������]', message_color)
													end
												else
													sampAddChatMessage('[Hospital Helper] {ffffff}����������� ' .. message_color_hex .. '/' .. command.cmd .. ' [ID ������] [��������]', message_color)
												end
											elseif command.arg == '' then
												arg_check = true
											end
											
											if arg_check then
												lua_thread.create(function()
													local lines = {}

													for line in string.gmatch(modifiedText, "[^&]+") do
														table.insert(lines, line)
													end

													for _, line in ipairs(lines) do
														for tag, replacement in pairs(tagReplacements) do
															local success, result = pcall(string.gsub, line, "#" .. tag, replacement())
															if success then
																line = result
															else
																
															end
														end

														sampSendChat(line)
														
														wait(get_my_wait())
													end
												end)
											end
											
										end)
									end
									if imgui.IsItemHovered() then
										imgui.SetTooltip(u8"��������� ������� /"..command.cmd)
									end
								end
								
								imgui.SameLine()
								
								if imgui.SmallButton(fa.PEN_TO_SQUARE .. '##'..command.cmd) then
								
									change_description = command.description
									input_description = ffi.new("char[256]", u8(change_description))
									
									change_arg = command.arg
									if command.arg == '' then
										ComboTags[0] = 0
									elseif command.arg == '#arg' then	
										ComboTags[0] = 1
									elseif command.arg == '#arg_id' then
										ComboTags[0] = 2
									elseif command.arg == '#arg_id #arg2' then
										ComboTags[0] = 3
									end
									
									change_cmd = command.cmd
									input_cmd = ffi.new("char[256]", command.cmd)
									
									change_text = command.text:gsub('&', '\n')
									input_text = ffi.new("char[8192]", u8(change_text))
									
									
											
									BinderWindow[0] = true
									
								end
								if imgui.IsItemHovered() then
									imgui.SetTooltip(u8"��������� ������� /"..command.cmd)
								end
								
								--[[imgui.SameLine()
								
								if imgui.SmallButton(fa.CLONE .. '##'..command.cmd) then
									sampAddChatMessage('[Hospital Helper] {ffffff}������������ �������� �� ��������!', message_color)
								end
								if imgui.IsItemHovered() then
									imgui.SetTooltip(u8"����������� ������� /"..command.cmd)
								end]]
								
								
								
								
								
								imgui.Columns(1)
								imgui.Separator()
								

								
							
							end
							
							
							
							if imgui.Button(u8'������� ����� �������##new_cmd', imgui.ImVec2(580 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
								
								local new_cmd = {cmd = '', description = '����� ������� ��������� ����', text = '', arg = '', enable = true }

								table.insert(settings.commands, new_cmd)
								
								change_description = new_cmd.description
								input_description = ffi.new("char[256]", u8(change_description))
								
								change_arg = new_cmd.arg
								ComboTags[0] = 0
								
								change_cmd = new_cmd.cmd
								input_cmd = ffi.new("char[256]", new_cmd.cmd)
								
								change_text = new_cmd.text:gsub('&', '\n')
								input_text = ffi.new("char[8192]", u8(change_text))
								
								BinderWindow[0] = true
								
							end
							
					
						imgui.EndChild()
					end
				
					
						imgui.EndTabItem()
					end
					
					if imgui.BeginTabItem(fa.BARS..u8' ������� ��� 9-10 ������') then 
						if tonumber(settings.player_info.fraction_rank_number) == 9 or tonumber(settings.player_info.fraction_rank_number) == 10 then
							
							if imgui.BeginChild('##1', imgui.ImVec2(589 * MONET_DPI_SCALE, 333 * MONET_DPI_SCALE), true) then
				
								imgui.Columns(3)
								imgui.CenterColumnText(u8"�������")
								imgui.SetColumnWidth(-1, 170 * MONET_DPI_SCALE)
								imgui.NextColumn()
								imgui.CenterColumnText(u8"��������")
								imgui.SetColumnWidth(-1, 300 * MONET_DPI_SCALE)
								imgui.NextColumn()
								imgui.CenterColumnText(u8"��������")
								imgui.SetColumnWidth(-1, 150 * MONET_DPI_SCALE)
								imgui.Columns(1)
								
								imgui.Separator()
								
								for _, command in ipairs(settings.commands_manage) do
							
									imgui.Columns(3)
									
									if command.enable then
										imgui.CenterColumnText('/' .. u8(command.cmd))
										imgui.NextColumn()
										imgui.CenterColumnText(u8(command.description))
										imgui.NextColumn()
									else
										imgui.CenterColumnTextDisabled('/' .. u8(command.cmd))
										imgui.NextColumn()
										imgui.CenterColumnTextDisabled(u8(command.description))
										imgui.NextColumn()
									end
									
									imgui.Text('    ')
									
									imgui.SameLine()
									
									if command.enable then
										if imgui.SmallButton(fa.TOGGLE_ON .. '##'..command.cmd) then
											command.enable = not command.enable
											save(settings, path)
											sampUnregisterChatCommand(command.cmd)
										end
										if imgui.IsItemHovered() then
											imgui.SetTooltip(u8"���������� ������� /"..command.cmd)
										end
									else
										if imgui.SmallButton(fa.TOGGLE_OFF .. '##'..command.cmd) then
											command.enable = not command.enable
											save(settings, path)
											sampRegisterChatCommand(command.cmd, function(arg)
								
												local arg_check = false
												
												local modifiedText = command.text

												if command.arg == '#arg' then
													if arg and arg ~= '' then
														modifiedText = modifiedText:gsub('#arg', arg or "")
														arg_check = true
													else
														sampAddChatMessage('[Hospital Helper] {ffffff}����������� ' .. message_color_hex .. '/' .. command.cmd .. ' [��������]', message_color)
													end
												elseif command.arg == '#arg_id' then
													if arg and arg ~= '' and isParamID(arg) then
													
														modifiedText = modifiedText:gsub('#get_nick%(#arg_id%)', sampGetPlayerNickname(arg) or "")
														modifiedText = modifiedText:gsub('#get_ru_nick%(#arg_id%)', TranslateNick(sampGetPlayerNickname(arg)) or "")
														modifiedText = modifiedText:gsub('#get_rp_nick%(#arg_id%)', sampGetPlayerNickname(arg):gsub('_',' ') or "")
													
													
														modifiedText = modifiedText:gsub('#arg_id', arg or "")
														arg_check = true
													else
														sampAddChatMessage('[Hospital Helper] {ffffff}����������� ' .. message_color_hex .. '/' .. command.cmd .. ' [ID ������]', message_color)
													end
												elseif command.arg == '#arg_id #arg2' then
													if arg and arg ~= '' then
														local arg_id, arg2 = arg:match('(%d+) (.+)')
														if arg_id and arg2 and isParamID(arg_id) then
														
															modifiedText = modifiedText:gsub('#get_nick%(#arg_id%)', sampGetPlayerNickname(arg_id) or "")
															modifiedText = modifiedText:gsub('#get_ru_nick%(#arg_id%)', TranslateNick(sampGetPlayerNickname(arg_id)) or "")
															modifiedText = modifiedText:gsub('#get_rp_nick%(#arg_id%)', sampGetPlayerNickname(arg_id):gsub('_',' ') or "")
														
														
															modifiedText = modifiedText:gsub('#arg_id', arg_id or "")
															modifiedText = modifiedText:gsub('#arg2', arg2 or "")
															arg_check = true
														else
															sampAddChatMessage('[Hospital Helper] {ffffff}����������� ' .. message_color_hex .. '/' .. command.cmd .. ' [ID ������] [��������]', message_color)
														end
													else
														sampAddChatMessage('[Hospital Helper] {ffffff}����������� ' .. message_color_hex .. '/' .. command.cmd .. ' [ID ������] [��������]', message_color)
													end
												elseif command.arg == '' then
													arg_check = true
												end
												
												if arg_check then
													lua_thread.create(function()
														local lines = {}

														for line in string.gmatch(modifiedText, "[^&]+") do
															table.insert(lines, line)
														end

														for _, line in ipairs(lines) do
															for tag, replacement in pairs(tagReplacements) do
																local success, result = pcall(string.gsub, line, "#" .. tag, replacement())
																if success then
																	line = result
																else
																	
																end
															end

															sampSendChat(line)
															
															wait(get_my_wait())
														end
													end)
												end
												
											end)
										end
										if imgui.IsItemHovered() then
											imgui.SetTooltip(u8"��������� ������� /"..command.cmd)
										end
									end
									
									imgui.SameLine()
									
									if imgui.SmallButton(fa.PEN_TO_SQUARE .. '##'..command.cmd) then
									
										change_description = command.description
										input_description = ffi.new("char[256]", u8(change_description))
										
										change_arg = command.arg
										if command.arg == '' then
											ComboTags[0] = 0
										elseif command.arg == '#arg' then	
											ComboTags[0] = 1
										elseif command.arg == '#arg_id' then
											ComboTags[0] = 2
										elseif command.arg == '#arg_id #arg2' then
											ComboTags[0] = 3
										end
										
										change_cmd = command.cmd
										input_cmd = ffi.new("char[256]", command.cmd)
										
										change_text = command.text:gsub('&', '\n')
										input_text = ffi.new("char[8192]", u8(change_text))
										
										
												
										BinderWindow[0] = true
										
									end
									if imgui.IsItemHovered() then
										imgui.SetTooltip(u8"��������� ������� /"..command.cmd)
									end
									
									--[[imgui.SameLine()
									
									if imgui.SmallButton(fa.CLONE .. '##'..command.cmd) then
										sampAddChatMessage('[Hospital Helper] {ffffff}������������ �������� �� ��������!', message_color)
									end
									if imgui.IsItemHovered() then
										imgui.SetTooltip(u8"����������� ������� /"..command.cmd)
									end]]
									
									
									imgui.Columns(1)
									imgui.Separator()
								
								end
								
								imgui.Columns(3)
								imgui.CenterColumnText(u8"/vc")
								imgui.NextColumn()
								imgui.CenterColumnText(u8"������/������ VC ���� ����������")
								imgui.NextColumn()
								imgui.CenterColumnText(u8"����������")
								imgui.Columns(1)
								
								imgui.Separator()
								
								imgui.Columns(3)
								imgui.CenterColumnText(u8"/spawncar")
								imgui.NextColumn()
								imgui.CenterColumnText(u8"���������� �/� �����������")
								imgui.NextColumn()
								imgui.CenterColumnText(u8"����������")
								imgui.Columns(1)
								
								imgui.Separator()
								
								if imgui.Button(u8'������� ����� �������##new_cmd_9-10', imgui.ImVec2(580 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
								
									binder_create_command_9_10 = true
								
									local new_cmd = {cmd = '', description = '����� ������� ��������� ����', text = '', arg = '', enable = true }

									table.insert(settings.commands_manage, new_cmd)
									
									change_description = new_cmd.description
									input_description = ffi.new("char[256]", u8(change_description))
									
									change_arg = new_cmd.arg
									ComboTags[0] = 0
									
									change_cmd = new_cmd.cmd
									input_cmd = ffi.new("char[256]", new_cmd.cmd)
									
									change_text = new_cmd.text:gsub('&', '\n')
									input_text = ffi.new("char[8192]", u8(change_text))
									
									BinderWindow[0] = true
									
								end
								
								imgui.EndChild()
							end
							
						else
							imgui.Text(u8" � ��� ��� ������� � ������ ��������, ��� ��� �� "..settings.player_info.fraction_rank_number..u8" ����.")
						end
						imgui.EndTabItem() 
					end
					
					if imgui.BeginTabItem(fa.BARS..u8' �������������� �������') then 
						
						
						if isMonetLoader() then
							imgui.Text(u8'������� ������� ���� �������������� � �������:')
							imgui.Text(u8'��������� � ������ � ������� �� ������ "��������������" � ����� ���� ')
						else
							imgui.Text(u8'������� ������� ���� �������: F2')
							imgui.Text(u8'������� ������� ���� �������������� � �������:  ��� + R')
						end
						
						imgui.EndTabItem() 
					end
				
				
					imgui.EndTabBar() 
					
				end
				
				imgui.EndTabItem()
				
			end
			
			if imgui.BeginTabItem(fa.MONEY_CHECK_DOLLAR..u8' ������� ��������') then 
				
				imgui.PushItemWidth(65 * MONET_DPI_SCALE)
				if imgui.InputText(u8'  ������� ������ (SA $)', input_heal, 6) then
					settings.price.heal = u8:decode(ffi.string(input_heal))
					save(settings, path)
				end
				
				imgui.SameLine()
				
				imgui.SetCursorPosX(300 * MONET_DPI_SCALE)
				imgui.PushItemWidth(65 * MONET_DPI_SCALE)
				if imgui.InputText(u8'  ������� ������ (VC $)', input_heal_vc, 6) then
					settings.price.heal_vc = u8:decode(ffi.string(input_heal_vc))
					save(settings, path)
				end
				
				imgui.Separator()
				
				imgui.PushItemWidth(65 * MONET_DPI_SCALE)
				if imgui.InputText(u8'  ������� ��������� (SA $)', input_healactor, 8) then
					settings.price.healactor = u8:decode(ffi.string(input_healactor))
					save(settings, path)
				end
				
				imgui.SameLine()
				imgui.SetCursorPosX(300 * MONET_DPI_SCALE)
				imgui.PushItemWidth(65 * MONET_DPI_SCALE)
				if imgui.InputText(u8'  ������� ��������� (VC $)', input_healactor_vc, 8) then
					settings.price.healactor_vc = u8:decode(ffi.string(input_healactor_vc))
					save(settings, path)
				end
				
				imgui.Separator()
				
				imgui.PushItemWidth(65 * MONET_DPI_SCALE)
				if imgui.InputText(u8'  ���������� ���. ������� ��� �������', input_medosm, 8) then
					settings.price.medosm = u8:decode(ffi.string(input_medosm))
					save(settings, path)
				end
				
				imgui.Separator()
				
				imgui.PushItemWidth(65 * MONET_DPI_SCALE)
				if imgui.InputText(u8'  ���������� ���. ������������ ��� �������� ������', input_mticket, 8) then
					settings.price.mticket = u8:decode(ffi.string(input_mticket))
					save(settings, path)
				end
				
				imgui.Separator()
				
				imgui.PushItemWidth(65 * MONET_DPI_SCALE)
				if imgui.InputText(u8'  ������ �������', input_recept, 8) then
					settings.price.recept = u8:decode(ffi.string(input_recept))
					save(settings, path)
				end
				
				imgui.Separator()
				
				imgui.PushItemWidth(65 * MONET_DPI_SCALE)
				if imgui.InputText(u8'  ������ �����������', input_ant, 8) then
					settings.price.ant = u8:decode(ffi.string(input_ant))
					save(settings, path)
				end
				
				imgui.Separator()
				
				imgui.PushItemWidth(65 * MONET_DPI_SCALE)
				if imgui.InputText(u8'  �������� ����������', input_tatu, 8) then
					settings.price.tatu = u8:decode(ffi.string(input_tatu))
					save(settings, path)
				end
				
				imgui.Separator()
				
				
				imgui.PushItemWidth(65 * MONET_DPI_SCALE)
				if imgui.InputText(u8'  ������ ���.����� �� 7 ����', input_med7, 8) then
					settings.price.med7 = u8:decode(ffi.string(input_med7))
					save(settings, path)
				end
				
			
				imgui.PushItemWidth(65 * MONET_DPI_SCALE)
				if imgui.InputText(u8'  ������ ���.����� �� 14 ����', input_med14, 8) then
					settings.price.med14 = u8:decode(ffi.string(input_med14))
					save(settings, path)
				end
				
				imgui.Separator()
				
				imgui.PushItemWidth(65 * MONET_DPI_SCALE)
				if imgui.InputText(u8'  ������ ���.����� �� 30 ����', input_med30, 8) then
					settings.price.med30 = u8:decode(ffi.string(input_med30))
					save(settings, path)
				end
				
				imgui.Separator()
				
				imgui.PushItemWidth(65 * MONET_DPI_SCALE)
				if imgui.InputText(u8'  ������ ���.����� �� 60 ����', input_med60, 8) then
					settings.price.med60 = u8:decode(ffi.string(input_med60))
					save(settings, path)
				end

				

			imgui.EndTabItem()
			end
			
			if imgui.BeginTabItem(fa.FILE_PEN..u8' �������') then 
		
				if imgui.InputTextMultiline("##text_multiple", input_text_note, 8192, imgui.ImVec2(590 * MONET_DPI_SCALE, 361 * MONET_DPI_SCALE)) then
					settings.note.my_note = u8:decode(ffi.string(input_text_note)):gsub('\n', '&')
					save(settings, path)	
				end
					
				imgui.EndTabItem()
			end
			
			if imgui.BeginTabItem(fa.GEAR..u8' ���������') then 
			
				if imgui.BeginChild('##1', imgui.ImVec2(589 * MONET_DPI_SCALE, 145 * MONET_DPI_SCALE), true) then

					imgui.CenterText(fa.CIRCLE_INFO .. u8' �������������� ���������� ��� ������')
					imgui.Separator()
			
					imgui.Text(fa.CIRCLE_USER..u8" ����������� ������� �������: Falcoln")
					imgui.Separator()

					imgui.Text(fa.CODE..u8" ������������� �� ������ � ����������: OSPx & Dobrui Kola")
					
					imgui.Separator()
					
					imgui.Text(fa.CIRCLE_INFO..u8" ������ ������� ������� ������ ����������� � ���: "..thisScript().version)
					--[[ imgui.SameLine()
					if imgui.SmallButton(u8'��������� ������� ����������') then
						
					end]]
					
					imgui.Separator()
					
					imgui.Text(fa.HEADSET..u8" ���.��������� �� ������� (����, �����������):")
					imgui.SameLine()
					if imgui.SmallButton('https://discord.com/invite/qBPEYjfNhv') then
						if isMonetLoader() then
							openLink('https://discord.com/invite/qBPEYjfNhv')
						else
							imgui.Link('https://discord.com/invite/qBPEYjfNhv')
						end
					end
					
					imgui.Separator()
					
					imgui.Text(fa.GLOBE..u8" ���� ������� �� ������ BlastHack:")
					imgui.SameLine()
					if imgui.SmallButton('https://www.blast.hk/threads/195388') then
						if isMonetLoader() then 
							openLink('https://www.blast.hk/threads/195388')
						else
							imgui.Link('https://www.blast.hk/threads/195388')
						end
					end
					
					--imgui.Separator()
					
					--[[if imgui.Button(u8'��������� ������� ����� ������ �������') then
						sampAddChatMessage('[Hospital Helper] {ffffff}������� ���������� �������� �����������!',message_color)
					end]]
					
					--imgui.Separator()

				imgui.EndChild()
				end

					
				if imgui.BeginChild('##2', imgui.ImVec2(589 * MONET_DPI_SCALE, 140 * MONET_DPI_SCALE), true) then



					imgui.CenterText(fa.CLOCK .. u8' �������� ����� ����������� � ��������: ' .. math.floor(settings.waiting.my_wait * 1000) .. ' ' .. u8("�� (" .. math.floor(settings.waiting.my_wait) .. " ���.)" ))
					
					local width = imgui.GetWindowWidth()
					local calc = imgui.CalcTextSize(u8' �������� �������� ')
					imgui.SetCursorPosX( width / 2 - calc.x / 2 )


					if imgui.Button(u8' �������� �������� ##change_waiting') then
						imgui.OpenPopup(fa.CLOCK .. u8' �������� ����� �����������##waiting')
					end
					if imgui.BeginPopupModal(fa.CLOCK .. u8' �������� ����� �����������##waiting', _, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove) then
						imgui.PushItemWidth(200 * MONET_DPI_SCALE)
						imgui.SliderFloat(u8'##waiting', slider, 1, 3)

						if imgui.Button(u8'���������', imgui.ImVec2(200 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
							settings.waiting.my_wait = slider[0]
							save(settings, path)
							imgui.CloseCurrentPopup()
						end
						imgui.End()
					end
					
					imgui.Separator()

					imgui.CenterText(fa.PALETTE .. u8' �������� ���� �������:')

					if imgui.RadioButtonIntPtr(u8" MoonMonet (������������� ����) ", theme, 0) then
						theme[0] = 0
						
						local r,g,b = mmcolor[0] * 255, mmcolor[1] * 255, mmcolor[2] * 255
						local argb = join_argb(0, r, g, b)
						
						settings.general.moonmonet_theme_enable = true
						settings.general.moonmonet_theme_color = argb
						settings.general.message_color = "0x" .. argbToHexWithoutAlpha(0, r, g, b)
						settings.general.message_color_hex = '{' .. argbToHexWithoutAlpha(0, r, g, b) .. '}'
						save(settings, path)
						
						message_color = settings.general.message_color 
						message_color_hex = settings.general.message_color_hex
						
						apply_moonmonet_theme()
					end
					
					if theme[0] == 0 then

						imgui.SameLine()

						if imgui.ColorEdit3('## COLOR', mmcolor, imgui.ColorEditFlags.NoInputs) then
							local r,g,b = mmcolor[0] * 255, mmcolor[1] * 255, mmcolor[2] * 255
							local argb = join_argb(0, r, g, b)
							
							
							
							settings.general.message_color = "0x" .. argbToHexWithoutAlpha(0, r, g, b)
							settings.general.message_color_hex = '{' .. argbToHexWithoutAlpha(0, r, g, b) .. '}'
							settings.general.moonmonet_theme_color = argb
							
							message_color = settings.general.message_color 
							message_color_hex = settings.general.message_color_hex
							
							save(settings, path)
							
							
							if theme[0] == 0 then
								apply_moonmonet_theme()
							end
							
						end
					
					end

					if imgui.RadioButtonIntPtr(u8" Old Dark Theme ", theme, 1) then
						theme[0] = 1
						settings.general.moonmonet_theme_enable = false
						settings.general.message_color = 0xFF7E7E
						settings.general.message_color_hex = '{FF7E7E}'
						save(settings, path)
						
						
						message_color = settings.general.message_color 
						message_color_hex = settings.general.message_color_hex
						
						apply_dark_theme()
					end
			
			
			
				
					


				imgui.EndChild()
				end

				if imgui.BeginChild("Yes3",imgui.ImVec2(589 * MONET_DPI_SCALE, 65 * MONET_DPI_SCALE),true) then
					
					
				
					if imgui.Button(u8" ����� ��������� ���� �������� � ������ ������� � ����������� ���������� ", imgui.ImVec2(580 * MONET_DPI_SCALE, 55 * MONET_DPI_SCALE)) then
						imgui.OpenPopup(fa.TRIANGLE_EXCLAMATION .. u8' �� �������? ')
					end
					if imgui.BeginPopupModal(fa.TRIANGLE_EXCLAMATION .. u8' �� �������? ', _, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove) then
						
						if imgui.Button(u8'���, ��������', imgui.ImVec2(100 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
							imgui.CloseCurrentPopup()
						end
						
						imgui.SameLine()
						
						if imgui.Button(u8'��, ��������', imgui.ImVec2(100 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
							settings = default_settings
							save(settings,path)
							imgui.CloseCurrentPopup()
							reset_settings_bool = true
							thisScript():reload()
						end
						
						imgui.End()
					end
					
					
					
					
				
					
					
				end imgui.EndChild()

				imgui.EndTabItem()
			end
		
		imgui.EndTabBar() end
		
		imgui.End()
		
    end
)

local FastMenuWindow = imgui.OnFrame(
    function() return FastMenu[0] end,
    function(player)
	
		imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(300 * MONET_DPI_SCALE, 415 * MONET_DPI_SCALE), imgui.Cond.FirstUseEver)
		imgui.Begin(fa.USER_INJURED..' '..sampGetPlayerNickname(player_id)..'['..player_id..']##FastMenu', FastMenu, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove )
		
		if imgui.Button(u8"����������",imgui.ImVec2(290 * MONET_DPI_SCALE, 30 * MONET_DPI_SCALE)) then
			command("�����������",player_id)
			FastMenu[0] = false
		end
		
		if imgui.Button(u8"������� �� �����",imgui.ImVec2(290 * MONET_DPI_SCALE, 30 * MONET_DPI_SCALE)) then
			command("�� ����",player_id)
			FastMenu[0] = false
		end
		
		if imgui.Button(u8"������� �������",imgui.ImVec2(290 * MONET_DPI_SCALE, 30 * MONET_DPI_SCALE)) then
			command("/heal #arg_id",player_id)
			FastMenu[0] = false
		end
		
		if imgui.Button(u8"������� ���������",imgui.ImVec2(290 * MONET_DPI_SCALE, 30 * MONET_DPI_SCALE)) then
			command("/healactor #arg_id",player_id)
			FastMenu[0] = false
		end
		
		if imgui.Button(u8"������� �� ����������������",imgui.ImVec2(290 * MONET_DPI_SCALE, 30 * MONET_DPI_SCALE)) then
			command("/healbad #arg_id",player_id)
			FastMenu[0] = false
		end
		
		if imgui.Button(u8"���������� ���.���������",imgui.ImVec2(290 * MONET_DPI_SCALE, 30 * MONET_DPI_SCALE)) then
			command("/givemedinsurance #arg_id",player_id)
			FastMenu[0] = false
		end
		
		if imgui.Button(u8"���������� ���.�����",imgui.ImVec2(290 * MONET_DPI_SCALE, 30 * MONET_DPI_SCALE)) then
			medcard(player_id)
			FastMenu[0] = false
		end
		
		if imgui.Button(u8"���������� ���.������� ������",imgui.ImVec2(290 * MONET_DPI_SCALE, 30 * MONET_DPI_SCALE)) then
			command("/medcheck #arg_id",player_id)
			FastMenu[0] = false
		end
		
		if imgui.Button(u8"������ ������������",imgui.ImVec2(290 * MONET_DPI_SCALE, 30 * MONET_DPI_SCALE)) then
			antibiotik(player_id)
			FastMenu[0] = false
		end
		
		if imgui.Button(u8"������ ��������",imgui.ImVec2(290 * MONET_DPI_SCALE, 30 * MONET_DPI_SCALE)) then
			recept(player_id)
			FastMenu[0] = false
		end
		
		if imgui.Button(u8"������� �� ��������",imgui.ImVec2(290 * MONET_DPI_SCALE, 30 * MONET_DPI_SCALE)) then
			command("/expel #arg_id",player_id)
			FastMenu[0] = false
		end
	
		imgui.End()
		
    end
)

local MedCardMenu = imgui.OnFrame(
    function() return MedCardMenu[0] end,
    function(player)
	
		imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY - 100  * MONET_DPI_SCALE), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(340 * MONET_DPI_SCALE, 115 * MONET_DPI_SCALE), imgui.Cond.FirstUseEver)
		imgui.Begin(fa.HOSPITAL.." Hospital Helper##med", MedCardMenu, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoScrollbar )
		
		
		imgui.CenterText(u8'���.����� ��� ������ '..sampGetPlayerNickname(player_id))
		
		if imgui.RadioButtonIntPtr(u8" 7 ���� ##0",medcard_days,0) then
			medcard_days[0] = 0
		end
		imgui.SameLine()
		
		if imgui.RadioButtonIntPtr(u8" 14 ���� ##1",medcard_days,1) then
			medcard_days[0] = 1
		end
		imgui.SameLine()
		
		if imgui.RadioButtonIntPtr(u8" 30 ���� ##2",medcard_days,2) then
			medcard_days[0] = 2
		end
		imgui.SameLine()
		
		if imgui.RadioButtonIntPtr(u8" 60 ���� ##3",medcard_days,3) then
			medcard_days[0] = 3
		end
		
		imgui.Separator()
		
		local width = imgui.GetWindowWidth()
		local calc = imgui.CalcTextSize(u8"������ ���.�����")
		imgui.SetCursorPosX( width / 2 - calc.x / 2 )
		if imgui.Button(fa.ID_CARD_CLIP..u8" ������ ���.�����") then
			
			lua_thread.create(function()
			
				sampSendChat("������, ����� ��������� � ����������.")
				wait(get_my_wait())
				sampSendChat("/me ������ �� ������ ���.����� ������ ���.�����, ����� � ������ ".. settings.player_info.fraction_tag .. ".")
				wait(get_my_wait())
				sampSendChat("/me ��������� ������ ���.����� � �������� � ���������, ����� ������ ������ ".. settings.player_info.fraction_tag .. ".")
				wait(get_my_wait())
				sampSendChat("/me �������� �������� ���.����� ������� ����� � ������ ������� � ���� ���.����.")
				wait(get_my_wait())
				sampSendChat("/todo ��� ���� ���.�����, ������*���������� ����������� ���.����� �������� �������� ����")
				wait(get_my_wait())
	
				if medcard_days[0] == 0 then
					sampSendChat("/medcard "..player_id.." 3 0 "..settings.price.med7)
				elseif medcard_days[0] == 1 then
					sampSendChat("/medcard "..player_id.." 3 1 "..settings.price.med14)
				elseif medcard_days[0] == 2 then
					sampSendChat("/medcard "..player_id.." 3 2 "..settings.price.med30)
				elseif medcard_days[0] == 3 then
					sampSendChat("/medcard "..player_id.." 3 3 "..settings.price.med60)
				end
				
			end)
			MedCardMenu[0] = false
			
		end
		
		imgui.End()
		
    end
)

local ReceptMenu = imgui.OnFrame(
    function() return ReceptMenu[0] end,
    function(player)
	

		imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY - 100  * MONET_DPI_SCALE), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(340 * MONET_DPI_SCALE, 130 * MONET_DPI_SCALE), imgui.Cond.FirstUseEver)
		imgui.Begin(fa.HOSPITAL.." Hospital Helper##recept", ReceptMenu, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoScrollbar )

		
        imgui.CenterText(u8'������� ��� ������ '..sampGetPlayerNickname(player_id))
        imgui.CenterText(u8'(������� ���-�� �������� ��� ������)')
	
		local buttonWidth = 40 * MONET_DPI_SCALE -- Adjust the width of the radio buttons as needed
		local totalButtonWidth = buttonWidth * 5 + imgui.GetStyle().ItemSpacing.x * 4
		local startPosX = imgui.GetWindowWidth() / 2 - totalButtonWidth / 2

		imgui.SetCursorPosX(startPosX)
		if imgui.RadioButtonIntPtr(u8" 1 ##rec0", recepts, 0) then
			recepts[0] = 0
		end

		imgui.SameLine()

		imgui.SetCursorPosX(startPosX + buttonWidth + imgui.GetStyle().ItemSpacing.x)
		if imgui.RadioButtonIntPtr(u8" 2 ##rec1", recepts, 1) then
			recepts[0] = 1
		end

		imgui.SameLine()

		imgui.SetCursorPosX(startPosX + 2 * (buttonWidth + imgui.GetStyle().ItemSpacing.x))
		if imgui.RadioButtonIntPtr(u8" 3 ##rec2", recepts, 2) then
			recepts[0] = 2
		end

		imgui.SameLine()

		imgui.SetCursorPosX(startPosX + 3 * (buttonWidth + imgui.GetStyle().ItemSpacing.x))
		if imgui.RadioButtonIntPtr(u8" 4 ##rec3", recepts, 3) then
			recepts[0] = 3
		end

		imgui.SameLine()

		imgui.SetCursorPosX(startPosX + 4 * (buttonWidth + imgui.GetStyle().ItemSpacing.x))
		if imgui.RadioButtonIntPtr(u8" 5 ##rec4", recepts, 4) then
			recepts[0] = 4
		end

		imgui.Separator()

        local width = imgui.GetWindowWidth()
        local calc = imgui.CalcTextSize(u8"������ �������")
        imgui.SetCursorPosX(width / 2 - calc.x / 2)


		if imgui.Button(fa.RECEIPT..u8" ������ �������") then
			
			lua_thread.create(function()
				sampSendChat("������, ������ � ����� ��� �������.")
				wait(get_my_wait())
				sampSendChat("/me ������ �� ������ ���.����� ����� ��� ���������� �������� � ������ ��� ���������.")
				wait(get_my_wait())
				sampSendChat("/do ����� ������� ��������.")
				wait(get_my_wait())
				sampSendChat("/todo ���, �������!*��������� ����� � ��������� �������� ��������")
				wait(get_my_wait())
				sampSendChat("/recept "..player_id.." "..tonumber(recepts[0])+1)
			end)
			ReceptMenu[0] = false
			
		end

        imgui.End()
		
    end
)

local AntibiotikMenu = imgui.OnFrame(
    function() return AntibiotikMenu[0] end,
    function(player)
	
		imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY - 100 * MONET_DPI_SCALE), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(340 * MONET_DPI_SCALE, 130 * MONET_DPI_SCALE), imgui.Cond.FirstUseEver)
		imgui.Begin(fa.HOSPITAL.." Hospital Helper##ant", AntibiotikMenu, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoScrollbar )
		
		
		imgui.CenterText(u8'����������� ��� ������ '..sampGetPlayerNickname(player_id))
		imgui.CenterText(u8'(������� ���-�� ������������ ��� ������)')
		--imgui.SetCursorPosX(30)
		
		
		imgui.PushItemWidth(300*MONET_DPI_SCALE)
		imgui.SliderInt('', antibiotiks, 1, 20)

		imgui.Separator()
		
		local width = imgui.GetWindowWidth()
		local calc = imgui.CalcTextSize(u8"������ �����������")
		imgui.SetCursorPosX( width / 2 - calc.x / 2 )
		if imgui.Button(fa.CAPSULES..u8" ������ �����������") then
			
			lua_thread.create(function()
				sampSendChat("������, ������ � ����� ��� �����������.")
				wait(get_my_wait())
				sampSendChat("/me ��������� ���� ���.���� � ������ �� ���� ����� ������������, ����� ���� ��������� ���.����.")
				wait(get_my_wait())
				sampSendChat("/do ����������� ��������� � �����.")
				wait(get_my_wait())
				sampSendChat("/todo ��� �������, ������������ �� ������ �� �������!*��������� ����������� �������� ��������")
				wait(get_my_wait())
				sampSendChat("/antibiotik "..player_id.." "..antibiotiks[0])
			end)
			AntibiotikMenu[0] = false
			
		end
		
		imgui.End()
		
    end
)

local MedOsmotrMenu2 = imgui.OnFrame(
    function() return  MedOsmotrMenu2[0] end,
    function(player)
	
		imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY - (100 * MONET_DPI_SCALE)), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(400 * MONET_DPI_SCALE, 130 * MONET_DPI_SCALE), imgui.Cond.FirstUseEver)
		imgui.Begin(fa.HOSPITAL.." Hospital Helper##medosm2",  MedOsmotrMenu2, imgui.WindowFlags.NoCollapse )
		
		imgui.CenterText(u8'���������� ���.������� ��� ������ '..sampGetPlayerNickname(player_id))
		imgui.Separator()
		
		imgui.CenterText(u8"�������� ���� ������� ������� ��� ���.�����.")
			
		imgui.CenterText("")
		imgui.Separator()
		
		local width = imgui.GetWindowWidth()
		local calc = imgui.CalcTextSize(u8"� ������ ��� ���.�����")
		imgui.SetCursorPosX( width / 2 - calc.x / 2 )
		if imgui.Button(fa.TRIANGLE_EXCLAMATION..u8" � ������ ��� ���.�����") then
			lua_thread.create(function()
				MedOsmotrMenu2[0] = false
				sampSendChat("��� ����� ����� ��� � ��� ���� ���.�����, � ����� ����� �������� �����������!")
				wait(get_my_wait())
				sampSendChat("/me ������ �� ���.����� ���������� �������� � �������� �� �� ����.")
				wait(get_my_wait())
				sampSendChat("/do �������� �� �����.")
				wait(get_my_wait())
				sampSendChat("/todo ������ ���.������*��������.")
				wait(get_my_wait())
				sampSendChat("������ � ������� ���� �����, �������� ��� � �������� ����.")
				wait(get_my_wait())
				sampSendChat("/n ����������� /me ������(-�) ���.")
				medcheck_no_medcard = true
				MedOsmotrMenu4[0] = true
			end)
		end
		
		imgui.End()
		
    end
)
local MedOsmotrMenu3 = imgui.OnFrame(
    function() return  MedOsmotrMenu3[0] end,
    function(player)
	
		imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY - (100 * MONET_DPI_SCALE)), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(400 * MONET_DPI_SCALE, 130 * MONET_DPI_SCALE), imgui.Cond.FirstUseEver)
		imgui.Begin(fa.HOSPITAL.." Hospital Helper##medosm3",  MedOsmotrMenu3, imgui.WindowFlags.NoCollapse )
		
		imgui.CenterText(u8'���������� ���.������� ��� ������ '..sampGetPlayerNickname(player_id))
		imgui.Separator()
		
		imgui.CenterText(fa.ID_CARD_CLIP..u8" ������ ���.�����: "..u8(medcard_status))
		imgui.CenterText(fa.CANNABIS..u8" ����������������: "..medcard_narko)
		
		imgui.Separator()
		
		if not medcard_status == "��������� ��������(��)" or tonumber(medcard_narko) > 0 then
		
			local width = imgui.GetWindowWidth()
			local calc = imgui.CalcTextSize(u8"�������� � �������� � ����������")
			imgui.SetCursorPosX( width / 2 - calc.x / 2 )
			
			if imgui.Button(fa.CIRCLE_RIGHT..u8" �������� � �������� � ����������") then
				lua_thread.create(function()
					MedOsmotrMenu3[0] = false
					if not medcard_status == "��������� ��������(��)" and tonumber(medcard_narko) > 0 then
						sampSendChat("� ��� ���� ���������������� "..tonumber(medcard_narko).." ������, � ������ �������� "..medcard_status.."!")
					elseif tonumber(medcard_narko) > 0 then
						sampSendChat("� ��� ���� ���������������� "..tonumber(medcard_narko).." ������!")
					elseif not medcard_status == "��������� ��������(��)" then
						sampSendChat("� ��� ������ �������� "..medcard_status..", ��� ����� �����!")
					end
					wait(get_my_wait())
					sampSendChat("/me ������ �� ���.����� ���������� �������� � �������� �� �� ����.")
					wait(get_my_wait())
					sampSendChat("/do �������� �� �����.")
					wait(get_my_wait())
					sampSendChat("/todo ������ ���.������*��������.")
					wait(get_my_wait())
					sampSendChat("������ � ������� ���� �����, �������� ��� � �������� ����.")
					wait(get_my_wait())
					sampSendChat("/n ����������� /me ������(-�) ���.")
					MedOsmotrMenu4[0] = true
				end)
			end
			
		else
		
			local width = imgui.GetWindowWidth()
			local calc = imgui.CalcTextSize(u8"����������")
			imgui.SetCursorPosX( width / 2 - calc.x / 2 )
			
			if imgui.Button(fa.CIRCLE_RIGHT..u8" ����������") then
				lua_thread.create(function()
					MedOsmotrMenu3[0] = false
					sampSendChat("���-�, � ���.������ � ��� ��� � �������, ���������...")
					wait(get_my_wait())
					sampSendChat("/me ������ �� ���.����� ���������� �������� � �������� �� �� ����.")
					wait(get_my_wait())
					sampSendChat("/do �������� �� �����.")
					wait(get_my_wait())
					sampSendChat("/todo ������ ���.������*��������.")
					wait(get_my_wait())
					sampSendChat("������ � ������� ���� �����, �������� ��� � �������� ����.")
					wait(get_my_wait())
					sampSendChat("/n ����������� /me ������(-�) ���.")
					MedOsmotrMenu4[0] = true
				end)
			end
			
		end
		
		imgui.End()
		
    end
)
local MedOsmotrMenu4 = imgui.OnFrame(
    function() return  MedOsmotrMenu4[0] end,
    function(player)
	
		imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY - (100 * MONET_DPI_SCALE)), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(400 * MONET_DPI_SCALE, 130 * MONET_DPI_SCALE), imgui.Cond.FirstUseEver)
		imgui.Begin(fa.HOSPITAL.." Hospital Helper##medosm4",  MedOsmotrMenu4, imgui.WindowFlags.NoCollapse )
		
		imgui.CenterText(u8'���������� ���.������� ��� ������ '..sampGetPlayerNickname(player_id))
		imgui.Separator()
		
		imgui.CenterText(u8"�������� ���� ������� ������� ��� � ������� ������.")
		imgui.CenterText("")
		imgui.Separator()
		
		local width = imgui.GetWindowWidth()
		local calc = imgui.CalcTextSize(u8"����������")
		imgui.SetCursorPosX( width / 2 - calc.x / 2 )
		if imgui.Button(fa.CIRCLE_RIGHT..u8" ����������") then
			lua_thread.create(function()
				MedOsmotrMenu4[0] = false
				sampSendChat("/me ������ �� ���.����� ������� � ������� ��� ����������� ����� �������� ��������.")
				wait(get_my_wait())
				sampSendChat("������, ������ ��������� ���, ������ � ������� ���� �����.")
				wait(get_my_wait())
				sampSendChat("/me ��������� ������� �������� �� ����, �������� ������� � �����.")
				wait(get_my_wait())
				sampSendChat("/do ������ ���� ������������ �������� ��������.")
				wait(get_my_wait())
				sampSendChat("/todo �������*�������� ������� � ������ ��� � ���.����")
				wait(get_my_wait())
				sampSendChat("����, ������ � ������� ���� ������������, ������� ������������ ������� ������!")
				wait(get_my_wait())
				sampSendChat("/n ����������� ������� /showtatu ���� ����� ������� ������!")
				MedOsmotrMenu5[0] = true
			end)
			
		end
		
		imgui.End()
		
    end
)
local MedOsmotrMenu5 = imgui.OnFrame(
    function() return  MedOsmotrMenu5[0] end,
    function(player)
	
		imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY - (100 * MONET_DPI_SCALE)), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(400 * MONET_DPI_SCALE, 130 * MONET_DPI_SCALE), imgui.Cond.FirstUseEver)
		imgui.Begin(fa.HOSPITAL.." Hospital Helper##medosm5",  MedOsmotrMenu5, imgui.WindowFlags.NoCollapse )
		
		imgui.CenterText(u8'���������� ���.������� ��� ������ '..sampGetPlayerNickname(player_id))
		imgui.Separator()

		imgui.CenterText(u8"�������� ���� ������� ����������� ������ � ������� ������.")
		imgui.CenterText("")
		imgui.Separator()
		
		local width = imgui.GetWindowWidth()
		local calc = imgui.CalcTextSize(u8"����������")
		imgui.SetCursorPosX( width / 2 - calc.x / 2 )
		if imgui.Button(fa.CIRCLE_RIGHT..u8" ����������") then
			lua_thread.create(function()
				MedOsmotrMenu5[0] = false
				sampSendChat("/me ������ �� ���.����� ��������� � �������� ��� � ����� �������� ��������� ������������.")
				wait(get_my_wait())
				sampSendChat("/do ������������ � ������ " .. math.random(55,85) .. " ������ � ������.")
				wait(get_my_wait())
				sampSendChat("/todo � ������������� � ��� ��� � �������*������ ��������� ������� � ���.����")
				wait(get_my_wait())
				sampSendChat("/me ������� �� ����� ��� �������������� �������� � ����������� ��")
				wait(get_my_wait())
				sampSendChat("��, ���-� � ���� ��� �������...")
				wait(get_my_wait())
				
				if tonumber(medcard_narko) > 0 and not medcard_status == "��������� ��������(��)" then
					sampSendChat("� ��� ���� ���������������� � �������� � ���.������!")
					wait(get_my_wait())
					sampSendChat("������ �� �������, �������� ���� � ����� ��� ��� ����� ������")
				elseif tonumber(medcard_narko) > 0 then
					sampSendChat("� ��� ���� ����������������!")
					wait(get_my_wait())
					sampSendChat("������ �� �������, �������� ���� � ����� ��� ��� ����� ������")
				elseif medcheck_no_medcard then
					medcheck_no_medcard = false
					sampSendChat("�� ��������� � ��� ��� � �������, �� � ��� ���� ���.�����!")
					wait(get_my_wait())
					sampSendChat("������ �� �������, �������� ���� � ����� ��� ��� ����� ������")
				else
					sampSendChat("�� ��������� � ��� ��� � �������!")
				end
				
				medcard_narko = 0
				medcard_status = ''
				
				medcheck = false
				
			end)
			
		end

		imgui.End()
		
    end
)

local binder_tags_text = [[
#my_id - ��� ������� ID
#my_nick- ��� ������� Nick
#my_ru_nick - ���� ��� � ������� ��������� � �������
#fraction - ���� ������� ��������� � �������
#fraction_tag - ��� ������������ ��� ��������� � �������
#fraction_rank - �������� ������ ������������ ����� � �������
#expel_reason - ������� ��� ������ �� �������
#price_heal - ���� ������� ���������
#price_actorheal - ���� ������� ����������
#price_medosm - ���� ���.������� ��� ������
#price_tatu - ���� �������� ����������
#price_mticket - ���� ������������ �������� ������ 
#price_ant - ���� �����������
#price_recept - ���� �������
#price_med7 - ���� ��������� �� 7 ����
#price_med14 - ���� ��������� �� 14 ����
#price_med30 - ���� ��������� �� 30 ����
#price_med60 - ���� ��������� �� 60 ����

#sex - ��������� ����� "�" ���� � ������� ������ ������� ���
#get_nick(#arg_id) - �������� Nick ������ �� ��������� ID ������
#get_rp_nick(#arg_id) - �������� Nick ������ ��� ������� _ �� ��������� ID ������
#get_ru_nick(#arg_id) - �������� Nick ������ �� �������� �� ��������� ID ������ ]]

local BinderWindow = imgui.OnFrame(
    function() return BinderWindow[0] end,
    function(player)
	
		imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(600 * MONET_DPI_SCALE, 425	* MONET_DPI_SCALE), imgui.Cond.FirstUseEver)
		
		imgui.Begin(fa.PEN_TO_SQUARE .. u8' �������������� ������� /' .. change_cmd, BinderWindow, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove )
		
		if imgui.BeginChild('##binder_edit', imgui.ImVec2(589 * MONET_DPI_SCALE, 350 * MONET_DPI_SCALE), true) then
		
			imgui.CenterText(u8'�������� �������:')
			imgui.PushItemWidth(579 * MONET_DPI_SCALE)
			imgui.InputText("##input_description", input_description, 256)
			
			imgui.Separator()
			
			imgui.CenterText(u8'������� ��� ������������� � ���� (��� /):')
			imgui.PushItemWidth(579 * MONET_DPI_SCALE)
			imgui.InputText("##input_cmd", input_cmd, 256)
			
			imgui.Separator()
			
			imgui.CenterText(u8'��������� ������� ��������� �������:')
	    	imgui.Combo(u8'',ComboTags, ImItems, #item_list)
		
	 	    imgui.Separator()
	
	        imgui.CenterText(u8'��������� ���� �������:')
		    if imgui.InputTextMultiline("##text_multiple", input_text, 8192, imgui.ImVec2(590 * MONET_DPI_SCALE, 161 * MONET_DPI_SCALE)) then
				input_text_string = u8:decode(ffi.string(input_text))
				input_text_string = input_text_string:gsub('\n', '&')
			end
			
		imgui.EndChild() end

		if imgui.Button(u8'������', imgui.ImVec2(  (imgui.GetWindowWidth() / 3) - (5 * MONET_DPI_SCALE) , 35 * MONET_DPI_SCALE)) then
			BinderWindow[0] = false
		end
		imgui.SameLine()
		if imgui.Button(u8'������ ��������� �����', imgui.ImVec2( (imgui.GetWindowWidth() / 3) - (10 * MONET_DPI_SCALE), 35 * MONET_DPI_SCALE)) then
			imgui.OpenPopup(fa.TAGS .. u8' ������ ���� ��������� �����')
		end
		if imgui.BeginPopupModal(fa.TAGS .. u8' ������ ���� ��������� �����', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoScrollbar ) then
			imgui.Text(u8(binder_tags_text))
			imgui.Separator()
			if imgui.Button(u8'�������', imgui.ImVec2(500 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
				imgui.CloseCurrentPopup()
			end
			imgui.End()
		end
		imgui.SameLine()

		if imgui.Button(u8'���������', imgui.ImVec2( (imgui.GetWindowWidth() / 3) - (10 * MONET_DPI_SCALE), 35 * MONET_DPI_SCALE)) then	
			
			if ffi.string(input_cmd):find('%W') or ffi.string(input_cmd) == '' or ffi.string(input_description) == '' or ffi.string(input_text) == '' then
			
				imgui.OpenPopup(fa.TRIANGLE_EXCLAMATION .. u8' ������ ���������� �������!')
				
			else
			
				local new_arg = ''
			
				if ComboTags[0] == 0 then
					new_arg = ''
				elseif ComboTags[0] == 1 then
					new_arg = '#arg'
				elseif ComboTags[0] == 2 then
					new_arg = '#arg_id'
				elseif ComboTags[0] == 3 then
					new_arg = '#arg_id #arg2'
				end
				
				local new_description = u8:decode(ffi.string(input_description))
				local new_command = u8:decode(ffi.string(input_cmd))
				local new_text = u8:decode(ffi.string(input_text)):gsub('\n', '&')
				
				if binder_create_command_9_10 then
				
					for _, command in ipairs(settings.commands_manage) do

					if command.cmd == change_cmd and command.description == change_description and command.arg == change_arg and command.text:gsub('&', '\n') == change_text then
						
						command.cmd = new_command
						command.arg = new_arg
						command.description = new_description
						command.text = new_text
						
						save(settings, path)
						
						if command.arg == '' then
							sampAddChatMessage('[Hospital Helper] {ffffff}������� ' .. message_color_hex .. '/' .. new_command .. ' {ffffff}������� ���������!', message_color)
						elseif command.arg == '#arg' then
							sampAddChatMessage('[Hospital Helper] {ffffff}������� ' .. message_color_hex .. '/' .. new_command .. ' [arg] {ffffff}������� ���������!', message_color)
						elseif command.arg == '#arg_id' then
							sampAddChatMessage('[Hospital Helper] {ffffff}������� ' .. message_color_hex .. '/' .. new_command .. ' [ID] {ffffff}������� ���������!', message_color)
						elseif command.arg == '#arg_id #arg2' then
							sampAddChatMessage('[Hospital Helper] {ffffff}������� ' .. message_color_hex .. '/' .. new_command .. ' [ID] [arg] {ffffff}������� ���������!', message_color)
						end
						
					
						
						sampUnregisterChatCommand(change_cmd)
						
						sampRegisterChatCommand(command.cmd, function(arg)
			
							local arg_check = false
							
							local modifiedText = command.text

							if command.arg == '#arg' then
								if arg and arg ~= '' then
									modifiedText = modifiedText:gsub('#arg', arg or "")
									arg_check = true
								else
									sampAddChatMessage('[Hospital Helper] {ffffff}����������� ' .. message_color_hex .. '/' .. command.cmd .. ' [��������]', message_color)
									play_error_sound()
								end
							elseif command.arg == '#arg_id' then
								if arg and arg ~= '' and isParamID(arg) then
									modifiedText = modifiedText:gsub('#get_nick%(#arg_id%)', sampGetPlayerNickname(arg) or "")
									modifiedText = modifiedText:gsub('#get_ru_nick%(#arg_id%)', TranslateNick(sampGetPlayerNickname(arg)) or "")
									modifiedText = modifiedText:gsub('#get_rp_nick%(#arg_id%)', sampGetPlayerNickname(arg):gsub('_',' ') or "")
									modifiedText = modifiedText:gsub('#arg_id', arg or "")
									arg_check = true
								else
									sampAddChatMessage('[Hospital Helper] {ffffff}����������� ' .. message_color_hex .. '/' .. command.cmd .. ' [ID ������]', message_color)
									play_error_sound()
								end
							elseif command.arg == '#arg_id #arg2' then
								if arg and arg ~= '' then
									local arg_id, arg2 = arg:match('(%d+) (.+)')
									if arg_id and arg2 and isParamID(arg_id) then
										modifiedText = modifiedText:gsub('#get_nick%(#arg_id%)', sampGetPlayerNickname(arg_id) or "")
										modifiedText = modifiedText:gsub('#get_ru_nick%(#arg_id%)', TranslateNick(sampGetPlayerNickname(arg_id)) or "")
										modifiedText = modifiedText:gsub('#get_rp_nick%(#arg_id%)', sampGetPlayerNickname(arg_id):gsub('_',' ') or "")
										modifiedText = modifiedText:gsub('#arg_id', arg_id or "")
										modifiedText = modifiedText:gsub('#arg2', arg2 or "")
										arg_check = true
									else
										sampAddChatMessage('[Hospital Helper] {ffffff}����������� ' .. message_color_hex .. '/' .. command.cmd .. ' [ID ������] [��������]', message_color)
										play_error_sound()
									end
								else
									sampAddChatMessage('[Hospital Helper] {ffffff}����������� ' .. message_color_hex .. '/' .. command.cmd .. ' [ID ������] [��������]', message_color)
									play_error_sound()
								end
							elseif command.arg == '' then
								arg_check = true
							end
							
							if arg_check then
								lua_thread.create(function()
									local lines = {}

									for line in string.gmatch(modifiedText, "[^&]+") do
										table.insert(lines, line)
									end

									for _, line in ipairs(lines) do
										for tag, replacement in pairs(tagReplacements) do
											local success, result = pcall(string.gsub, line, "#" .. tag, replacement())
											if success then
												line = result
											else
												
											end
										end

										sampSendChat(line)
										
										wait(get_my_wait())
									end
								end)
							end
							
						end)
						
						
					end

				end
				
					binder_create_command_9_10 = false
				
				else
				
					for _, command in ipairs(settings.commands) do

					if command.cmd == change_cmd and command.description == change_description and command.arg == change_arg and command.text:gsub('&', '\n') == change_text then
						
						command.cmd = new_command
						command.arg = new_arg
						command.description = new_description
						command.text = new_text
						
						save(settings, path)
						
						if command.arg == '' then
							sampAddChatMessage('[Hospital Helper] {ffffff}������� ' .. message_color_hex .. '/' .. new_command .. ' {ffffff}������� ���������!', message_color)
						elseif command.arg == '#arg' then
							sampAddChatMessage('[Hospital Helper] {ffffff}������� ' .. message_color_hex .. '/' .. new_command .. ' [arg] {ffffff}������� ���������!', message_color)
						elseif command.arg == '#arg_id' then
							sampAddChatMessage('[Hospital Helper] {ffffff}������� ' .. message_color_hex .. '/' .. new_command .. ' [ID] {ffffff}������� ���������!', message_color)
						elseif command.arg == '#arg_id #arg2' then
							sampAddChatMessage('[Hospital Helper] {ffffff}������� ' .. message_color_hex .. '/' .. new_command .. ' [ID] [arg] {ffffff}������� ���������!', message_color)
						end
						
					
						
						sampUnregisterChatCommand(change_cmd)
						
						sampRegisterChatCommand(command.cmd, function(arg)
			
							local arg_check = false
							
							local modifiedText = command.text

							if command.arg == '#arg' then
								if arg and arg ~= '' then
									modifiedText = modifiedText:gsub('#arg', arg or "")
									arg_check = true
								else
									sampAddChatMessage('[Hospital Helper] {ffffff}����������� ' .. message_color_hex .. '/' .. command.cmd .. ' [��������]', message_color)
									play_error_sound()
								end
							elseif command.arg == '#arg_id' then
								if arg and arg ~= '' and isParamID(arg) then
									modifiedText = modifiedText:gsub('#get_nick%(#arg_id%)', sampGetPlayerNickname(arg) or "")
									modifiedText = modifiedText:gsub('#get_ru_nick%(#arg_id%)', TranslateNick(sampGetPlayerNickname(arg)) or "")
									modifiedText = modifiedText:gsub('#get_rp_nick%(#arg_id%)', sampGetPlayerNickname(arg):gsub('_',' ') or "")
									modifiedText = modifiedText:gsub('#arg_id', arg or "")
									arg_check = true
								else
									sampAddChatMessage('[Hospital Helper] {ffffff}����������� ' .. message_color_hex .. '/' .. command.cmd .. ' [ID ������]', message_color)
									play_error_sound()
								end
							elseif command.arg == '#arg_id #arg2' then
								if arg and arg ~= '' then
									local arg_id, arg2 = arg:match('(%d+) (.+)')
									if arg_id and arg2 and isParamID(arg_id) then
										modifiedText = modifiedText:gsub('#get_nick%(#arg_id%)', sampGetPlayerNickname(arg_id) or "")
										modifiedText = modifiedText:gsub('#get_ru_nick%(#arg_id%)', TranslateNick(sampGetPlayerNickname(arg_id)) or "")
										modifiedText = modifiedText:gsub('#get_rp_nick%(#arg_id%)', sampGetPlayerNickname(arg_id):gsub('_',' ') or "")
										modifiedText = modifiedText:gsub('#arg_id', arg_id or "")
										modifiedText = modifiedText:gsub('#arg2', arg2 or "")
										arg_check = true
									else
										sampAddChatMessage('[Hospital Helper] {ffffff}����������� ' .. message_color_hex .. '/' .. command.cmd .. ' [ID ������] [��������]', message_color)
										play_error_sound()
									end
								else
									sampAddChatMessage('[Hospital Helper] {ffffff}����������� ' .. message_color_hex .. '/' .. command.cmd .. ' [ID ������] [��������]', message_color)
									play_error_sound()
								end
							elseif command.arg == '' then
								arg_check = true
							end
							
							if arg_check then
								lua_thread.create(function()
									local lines = {}

									for line in string.gmatch(modifiedText, "[^&]+") do
										table.insert(lines, line)
									end

									for _, line in ipairs(lines) do
										for tag, replacement in pairs(tagReplacements) do
											local success, result = pcall(string.gsub, line, "#" .. tag, replacement())
											if success then
												line = result
											else
												
											end
										end

										sampSendChat(line)
										
										wait(get_my_wait())
									end
								end)
							end
							
						end)
						
						
					end

				end
				
				end
				
				BinderWindow[0] = false
			
			end
			
		end
		if imgui.BeginPopupModal(fa.TRIANGLE_EXCLAMATION .. u8' ������ ���������� �������!', _, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove) then
			
			if ffi.string(input_cmd):find('%W') then
				imgui.BulletText(u8" � ������� ����� ������������ ������ ����. ����� �/��� �����!")
			elseif ffi.string(input_cmd) == '' then
				imgui.BulletText(u8" ������� �� ����� ���� ������!")
			end
			
			if ffi.string(input_description) == '' then
				imgui.BulletText(u8" �������� ������� �� ����� ���� ������!")
			end
			
			if ffi.string(input_text) == '' then
				imgui.BulletText(u8" ���� ������� �� ����� ���� ������!")
			end
			
			if imgui.Button(u8'�������', imgui.ImVec2(500 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
				imgui.CloseCurrentPopup()
			end
			
			imgui.End()
		end	
			
		
		
		imgui.End()
    end
)

local MembersWindow = imgui.OnFrame(
    function() return MembersWindow[0] end,
    function(player)

		if tonumber(#members) >= 16 then
			sizeYY = 413
		else
			sizeYY = 24.5 * ( tonumber(#members) + 1 )
		end

		imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(600 * MONET_DPI_SCALE, sizeYY * MONET_DPI_SCALE), imgui.Cond.FirstUseEver)
		
		local add = ''
		
		if tonumber(#members) == 1 then
			add = u8'���������'
		elseif tonumber(#members) > 1 and tonumber(#members) < 5 then
			add = u8'���������a'
		elseif tonumber(#members) >= 5 then
			add = u8'�����������'
		end
		
		imgui.Begin(fa.BUILDING_SHIELD .. " " ..  u8(members_fraction) .. " - " .. #members .. ' ' .. add .. u8' ������', MembersWindow, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove )

		
		for i, v in ipairs(members) do

			imgui.Columns(3)
			
			local r, g, b
			if v.working then r, g, b = 255, 255, 255 else r, g, b = 255, 59, 59 end
			local imgui_RGBA = imgui.ImVec4(r / 255.0, g / 255.0, b / 255.0, 1)
			
			if tonumber(v.afk) > 0 and tonumber(v.afk) < 60 then
				imgui.CenterColumnColorText(imgui_RGBA, u8(v.nick) .. ' [' .. v.id .. '] [AFK ' .. v.afk .. 's]')
			elseif tonumber(v.afk) >= 60 then
				imgui.CenterColumnColorText(imgui_RGBA, u8(v.nick) .. ' [' .. v.id .. '] [AFK ' .. math.floor( tonumber(v.afk) / 60 ) .. 'm]')
			else
				imgui.CenterColumnColorText(imgui_RGBA, u8(v.nick) .. ' [' .. v.id .. ']')
			end
			
			imgui.SetColumnWidth(-1, 300 * MONET_DPI_SCALE)
			imgui.NextColumn()
			imgui.CenterColumnText(u8(v.rank) .. ' (' .. u8(v.rank_number) .. ')')
			imgui.SetColumnWidth(-1, 230 * MONET_DPI_SCALE)
			imgui.NextColumn()
			imgui.CenterColumnText(u8(v.warns .. '/3'))
			imgui.SetColumnWidth(-1, 75 * MONET_DPI_SCALE)
			imgui.Columns(1)
			imgui.Separator()
				
		end
		
		imgui.End()
		
    end
)

local FastHealMenu = imgui.OnFrame(
    function() return FastHealMenu[0] end,
    function(player)
	
		
	
		imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 8.5, sizeY / 1.9), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		
		imgui.Begin(fa.HOSPITAL.." Hospital Helper##fast_heal", FastHealMenu, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoTitleBar +  imgui.WindowFlags.AlwaysAutoResize )
		
	
		
		if imgui.Button(fa.KIT_MEDICAL..u8' �������� '..sampGetPlayerNickname(heal_in_chat_player_id)) then
			command("/heal #arg_id",heal_in_chat_player_id)
			heal_in_chat = false
			heal_in_chat_id = nil
			FastHealMenu[0] = false
		end
	
		
		imgui.End()
		
    end
)

local FastMenuButton = imgui.OnFrame(
    function() return FastMenuButton[0] end,
    function(player)
	
		imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 8.5, sizeY / 2.3), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		
		imgui.Begin(fa.HOSPITAL.." Hospital Helper##fast_menu_button", FastMenuButton, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoTitleBar  )
		
		if imgui.Button(fa.IMAGE_PORTRAIT..u8' �������������� ') then
			
			if tonumber(#get_players()) == 1 then
				show_fast_menu(get_players()[1])
				FastMenuButton[0] = false
			elseif tonumber(#get_players()) > 1 then
				FastMenuPlayers[0] = true
				FastMenuButton[0] = false
			end
			
		end
	
		imgui.End()
		
    end
)

local FastMenuPlayers = imgui.OnFrame(
    function() return FastMenuPlayers[0] end,
    function(player)
	
		imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		
		imgui.Begin(fa.HOSPITAL..u8" �������� ������##fast_menu_players", FastMenuPlayers, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize  )
		
		if tonumber(#get_players()) == 0 then
			show_fast_menu(get_players()[1])
			FastMenuPlayers[0] = false
		elseif tonumber(#get_players()) >= 1 then
			for _, playerId in ipairs(get_players()) do
				local id = tonumber(playerId)
				if imgui.Button(sampGetPlayerNickname(id), imgui.ImVec2(200 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
					if tonumber(#get_players()) ~= 0 then show_fast_menu(id) end
					FastMenuPlayers[0] = false
				end
			end
		end

		imgui.End()
		
    end
)

function imgui.Link(link, text)
   
	text = text or link
    local tSize = imgui.CalcTextSize(text)
    local p = imgui.GetCursorScreenPos()
    local DL = imgui.GetWindowDrawList()
    local col = { 0xFFFF7700, 0xFFFF9900 }
    if imgui.InvisibleButton("##" .. link, tSize) then os.execute("explorer " .. link) end
    local color = imgui.IsItemHovered() and col[1] or col[2]
    DL:AddText(p, color, text)
    DL:AddLine(imgui.ImVec2(p.x, p.y + tSize.y), imgui.ImVec2(p.x + tSize.x, p.y + tSize.y), color)
end
function imgui.CenterText(text)
    local width = imgui.GetWindowWidth()
    local calc = imgui.CalcTextSize(text)
    imgui.SetCursorPosX( width / 2 - calc.x / 2 )
    imgui.Text(text)
end
function imgui.CenterColumnText(text)
    imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - imgui.CalcTextSize(text).x / 2)
    imgui.Text(text)
end
function imgui.CenterColumnTextDisabled(text)
    imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - imgui.CalcTextSize(text).x / 2)
    imgui.TextDisabled(text)
end
function imgui.CenterColumnColorText(imgui_RGBA, text)
    imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - imgui.CalcTextSize(text).x / 2)
	imgui.TextColored(imgui_RGBA, text)
end
function imgui.CenterColumnInputText(text,v,size)

	if text:find('^(.+)##(.+)') then
		local text1, text2 = text:match('(.+)##(.+)')
		imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - (imgui.CalcTextSize(text1).x / 2) - (imgui.CalcTextSize(v).x / 2 ))
	elseif text:find('^##(.+)') then
		imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2) ) - (imgui.CalcTextSize(v).x / 2 ) )
	else
		imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - (imgui.CalcTextSize(text).x / 2) - (imgui.CalcTextSize(v).x / 2 ))
	end   
	
	if imgui.InputText(text,v,size) then
		return true
	else
		return false
	end
	
end
function imgui.CenterColumnButton(text)

	if text:find('(.+)##(.+)') then
		local text1, text2 = text:match('(.+)##(.+)')
		imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - imgui.CalcTextSize(text1).x / 2)
	else
		imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - imgui.CalcTextSize(text).x / 2)
	end
	
    if imgui.Button(text) then
		return true
	else
		return false
	end
end
function imgui.CenterColumnSmallButton(text)

	if text:find('(.+)##(.+)') then
		local text1, text2 = text:match('(.+)##(.+)')
		imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - imgui.CalcTextSize(text1).x / 2)
	else
		imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - imgui.CalcTextSize(text).x / 2)
	end
	
    if imgui.SmallButton(text) then
		return true
	else
		return false
	end
	
end
function imgui.CenterTextDisabled(text)
    local width = imgui.GetWindowWidth()
    local calc = imgui.CalcTextSize(text)
    imgui.SetCursorPosX( width / 2 - calc.x / 2 )
    imgui.TextDisabled(text)
end

function apply_dark_theme()

	imgui.SwitchContext()
    imgui.GetStyle().WindowPadding = imgui.ImVec2(5 * MONET_DPI_SCALE, 5 * MONET_DPI_SCALE)
    imgui.GetStyle().FramePadding = imgui.ImVec2(5 * MONET_DPI_SCALE, 5 * MONET_DPI_SCALE)
    imgui.GetStyle().ItemSpacing = imgui.ImVec2(5 * MONET_DPI_SCALE, 5 * MONET_DPI_SCALE)
    imgui.GetStyle().ItemInnerSpacing = imgui.ImVec2(2 * MONET_DPI_SCALE, 2 * MONET_DPI_SCALE)
    imgui.GetStyle().TouchExtraPadding = imgui.ImVec2(0, 0)
    imgui.GetStyle().IndentSpacing = 0
    imgui.GetStyle().ScrollbarSize = 10 * MONET_DPI_SCALE
    imgui.GetStyle().GrabMinSize = 10 * MONET_DPI_SCALE
    imgui.GetStyle().WindowBorderSize = 1 * MONET_DPI_SCALE
    imgui.GetStyle().ChildBorderSize = 1 * MONET_DPI_SCALE
    imgui.GetStyle().PopupBorderSize = 1 * MONET_DPI_SCALE
    imgui.GetStyle().FrameBorderSize = 1 * MONET_DPI_SCALE
    imgui.GetStyle().TabBorderSize = 1 * MONET_DPI_SCALE
	imgui.GetStyle().WindowRounding = 8 * MONET_DPI_SCALE
    imgui.GetStyle().ChildRounding = 8 * MONET_DPI_SCALE
    imgui.GetStyle().FrameRounding = 8 * MONET_DPI_SCALE
    imgui.GetStyle().PopupRounding = 8 * MONET_DPI_SCALE
    imgui.GetStyle().ScrollbarRounding = 8 * MONET_DPI_SCALE
    imgui.GetStyle().GrabRounding = 8 * MONET_DPI_SCALE
    imgui.GetStyle().TabRounding = 8 * MONET_DPI_SCALE
    imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
    imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
    imgui.GetStyle().SelectableTextAlign = imgui.ImVec2(0.5, 0.5)
    
    imgui.GetStyle().Colors[imgui.Col.Text]                   = imgui.ImVec4(1.00, 1.00, 1.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TextDisabled]           = imgui.ImVec4(0.50, 0.50, 0.50, 1.00)
    imgui.GetStyle().Colors[imgui.Col.WindowBg]               = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ChildBg]                = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PopupBg]                = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Border]                 = imgui.ImVec4(0.25, 0.25, 0.26, 0.54)
    imgui.GetStyle().Colors[imgui.Col.BorderShadow]           = imgui.ImVec4(0.00, 0.00, 0.00, 0.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBg]                = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBgHovered]         = imgui.ImVec4(0.25, 0.25, 0.26, 1.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBgActive]          = imgui.ImVec4(0.25, 0.25, 0.26, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBg]                = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBgActive]          = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBgCollapsed]       = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.MenuBarBg]              = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarBg]            = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrab]          = imgui.ImVec4(0.00, 0.00, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabHovered]   = imgui.ImVec4(0.41, 0.41, 0.41, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabActive]    = imgui.ImVec4(0.51, 0.51, 0.51, 1.00)
    imgui.GetStyle().Colors[imgui.Col.CheckMark]              = imgui.ImVec4(1.00, 1.00, 1.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SliderGrab]             = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SliderGrabActive]       = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Button]                 = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ButtonHovered]          = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ButtonActive]           = imgui.ImVec4(0.41, 0.41, 0.41, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Header]                 = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.HeaderHovered]          = imgui.ImVec4(0.20, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.HeaderActive]           = imgui.ImVec4(0.47, 0.47, 0.47, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Separator]              = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SeparatorHovered]       = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SeparatorActive]        = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ResizeGrip]             = imgui.ImVec4(1.00, 1.00, 1.00, 0.25)
    imgui.GetStyle().Colors[imgui.Col.ResizeGripHovered]      = imgui.ImVec4(1.00, 1.00, 1.00, 0.67)
    imgui.GetStyle().Colors[imgui.Col.ResizeGripActive]       = imgui.ImVec4(1.00, 1.00, 1.00, 0.95)
    imgui.GetStyle().Colors[imgui.Col.Tab]                    = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TabHovered]             = imgui.ImVec4(0.28, 0.28, 0.28, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TabActive]              = imgui.ImVec4(0.30, 0.30, 0.30, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TabUnfocused]           = imgui.ImVec4(0.07, 0.10, 0.15, 0.97)
    imgui.GetStyle().Colors[imgui.Col.TabUnfocusedActive]     = imgui.ImVec4(0.14, 0.26, 0.42, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotLines]              = imgui.ImVec4(0.61, 0.61, 0.61, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotLinesHovered]       = imgui.ImVec4(1.00, 0.43, 0.35, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotHistogram]          = imgui.ImVec4(0.90, 0.70, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotHistogramHovered]   = imgui.ImVec4(1.00, 0.60, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TextSelectedBg]         = imgui.ImVec4(1.00, 0.00, 0.00, 0.35)
    imgui.GetStyle().Colors[imgui.Col.DragDropTarget]         = imgui.ImVec4(1.00, 1.00, 0.00, 0.90)
    imgui.GetStyle().Colors[imgui.Col.NavHighlight]           = imgui.ImVec4(0.26, 0.59, 0.98, 1.00)
    imgui.GetStyle().Colors[imgui.Col.NavWindowingHighlight]  = imgui.ImVec4(1.00, 1.00, 1.00, 0.70)
    imgui.GetStyle().Colors[imgui.Col.NavWindowingDimBg]      = imgui.ImVec4(0.80, 0.80, 0.80, 0.20)
    imgui.GetStyle().Colors[imgui.Col.ModalWindowDimBg]       = imgui.ImVec4(0.12, 0.12, 0.12, 0.95)
	
	
	
end

function apply_moonmonet_theme()
	imgui.SwitchContext()

	imgui.GetStyle().WindowPadding = imgui.ImVec2(5 * MONET_DPI_SCALE, 5 * MONET_DPI_SCALE)
    imgui.GetStyle().FramePadding = imgui.ImVec2(5 * MONET_DPI_SCALE, 5 * MONET_DPI_SCALE)
    imgui.GetStyle().ItemSpacing = imgui.ImVec2(5 * MONET_DPI_SCALE, 5 * MONET_DPI_SCALE)
    imgui.GetStyle().ItemInnerSpacing = imgui.ImVec2(2 * MONET_DPI_SCALE, 2 * MONET_DPI_SCALE)
    imgui.GetStyle().TouchExtraPadding = imgui.ImVec2(0, 0)
    imgui.GetStyle().IndentSpacing = 0
    imgui.GetStyle().ScrollbarSize = 10 * MONET_DPI_SCALE
    imgui.GetStyle().GrabMinSize = 10 * MONET_DPI_SCALE
    imgui.GetStyle().WindowBorderSize = 1 * MONET_DPI_SCALE
    imgui.GetStyle().ChildBorderSize = 1 * MONET_DPI_SCALE
    imgui.GetStyle().PopupBorderSize = 1 * MONET_DPI_SCALE
    imgui.GetStyle().FrameBorderSize = 1 * MONET_DPI_SCALE
    imgui.GetStyle().TabBorderSize = 1 * MONET_DPI_SCALE
	imgui.GetStyle().WindowRounding = 8 * MONET_DPI_SCALE
    imgui.GetStyle().ChildRounding = 8 * MONET_DPI_SCALE
    imgui.GetStyle().FrameRounding = 8 * MONET_DPI_SCALE
    imgui.GetStyle().PopupRounding = 8 * MONET_DPI_SCALE
    imgui.GetStyle().ScrollbarRounding = 8 * MONET_DPI_SCALE
    imgui.GetStyle().GrabRounding = 8 * MONET_DPI_SCALE
    imgui.GetStyle().TabRounding = 8 * MONET_DPI_SCALE
    imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
    imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
    imgui.GetStyle().SelectableTextAlign = imgui.ImVec2(0.5, 0.5)

	local style = imgui.GetStyle()
	local colors = style.Colors
	local clr = imgui.Col
	local ImVec4 = imgui.ImVec4
	local generated_color = monet.buildColors(settings.general.moonmonet_theme_color, 1.0, true)
	colors[clr.Text] = ColorAccentsAdapter(generated_color.accent2.color_50):as_vec4()
	colors[clr.TextDisabled] = ColorAccentsAdapter(generated_color.neutral1.color_600):as_vec4()
	colors[clr.WindowBg] = ColorAccentsAdapter(generated_color.accent2.color_900):as_vec4()
	colors[clr.ChildBg] = ColorAccentsAdapter(generated_color.accent2.color_800):as_vec4()
	colors[clr.PopupBg] = ColorAccentsAdapter(generated_color.accent2.color_700):as_vec4()
	colors[clr.Border] = ColorAccentsAdapter(generated_color.accent1.color_200):apply_alpha(0xcc):as_vec4()
	colors[clr.Separator] = ColorAccentsAdapter(generated_color.accent1.color_200):apply_alpha(0xcc):as_vec4()
	colors[clr.BorderShadow] = imgui.ImVec4(0.00, 0.00, 0.00, 0.00)
	colors[clr.FrameBg] = ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0x60):as_vec4()
	colors[clr.FrameBgHovered] = ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0x70):as_vec4()
	colors[clr.FrameBgActive] = ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0x50):as_vec4()
	colors[clr.TitleBg] = ColorAccentsAdapter(generated_color.accent2.color_700):apply_alpha(0xcc):as_vec4()
	colors[clr.TitleBgCollapsed] = ColorAccentsAdapter(generated_color.accent2.color_700):apply_alpha(0x7f):as_vec4()
	colors[clr.TitleBgActive] = ColorAccentsAdapter(generated_color.accent2.color_700):as_vec4()
	colors[clr.MenuBarBg] = ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0x91):as_vec4()
	colors[clr.ScrollbarBg] = imgui.ImVec4(0,0,0,0)
	colors[clr.ScrollbarGrab] = ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0x85):as_vec4()
	colors[clr.ScrollbarGrabHovered] = ColorAccentsAdapter(generated_color.accent1.color_600):as_vec4()
	colors[clr.ScrollbarGrabActive] = ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0xb3):as_vec4()
	colors[clr.CheckMark] = ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0xcc):as_vec4()
	colors[clr.SliderGrab] = ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0xcc):as_vec4()
	colors[clr.SliderGrabActive] = ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0x80):as_vec4()
	colors[clr.Button] = ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0xcc):as_vec4()
	colors[clr.ButtonHovered] = ColorAccentsAdapter(generated_color.accent1.color_600):as_vec4()
	colors[clr.ButtonActive] = ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0xb3):as_vec4()
	colors[clr.Tab] = ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0xcc):as_vec4()
	colors[clr.TabActive] = ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0xb3):as_vec4()
	colors[clr.TabHovered] = ColorAccentsAdapter(generated_color.accent1.color_600):as_vec4()
	colors[clr.Header] = ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0xcc):as_vec4()
	colors[clr.HeaderHovered] = ColorAccentsAdapter(generated_color.accent1.color_600):as_vec4()
	colors[clr.HeaderActive] = ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0xb3):as_vec4()
	colors[clr.ResizeGrip] = ColorAccentsAdapter(generated_color.accent2.color_700):apply_alpha(0xcc):as_vec4()
	colors[clr.ResizeGripHovered] = ColorAccentsAdapter(generated_color.accent2.color_700):as_vec4()
	colors[clr.ResizeGripActive] = ColorAccentsAdapter(generated_color.accent2.color_700):apply_alpha(0xb3):as_vec4()
	colors[clr.PlotLines] = ColorAccentsAdapter(generated_color.accent2.color_600):as_vec4()
	colors[clr.PlotLinesHovered] = ColorAccentsAdapter(generated_color.accent1.color_600):as_vec4()
	colors[clr.PlotHistogram] = ColorAccentsAdapter(generated_color.accent2.color_600):as_vec4()
	colors[clr.PlotHistogramHovered] = ColorAccentsAdapter(generated_color.accent1.color_600):as_vec4()
	colors[clr.TextSelectedBg] = ColorAccentsAdapter(generated_color.accent1.color_600):as_vec4()
	colors[clr.ModalWindowDimBg] = ColorAccentsAdapter(generated_color.accent1.color_200):apply_alpha(0x26):as_vec4()
end

function argbToHexWithoutAlpha(alpha, red, green, blue)
    return string.format("%02X%02X%02X", red, green, blue)
end
function join_argb(a, r, g, b)
    local argb = b  -- b
    argb = bit.bor(argb, bit.lshift(g, 8))  -- g
    argb = bit.bor(argb, bit.lshift(r, 16)) -- r     
    argb = bit.bor(argb, bit.lshift(a, 24)) -- a
    return argb
end
function explode_argb(argb)
    local a = bit.band(bit.rshift(argb, 24), 0xFF)
    local r = bit.band(bit.rshift(argb, 16), 0xFF)
    local g = bit.band(bit.rshift(argb, 8), 0xFF)
    local b = bit.band(argb, 0xFF)
    return a, r, g, b
end
function ARGBtoRGB(color)
    return bit.band(color, 0xFFFFFF)
end
function rgb2hex(r, g, b)
    local hex = string.format("#%02X%02X%02X", r, g, b)
    return hex
end
function ColorAccentsAdapter(color)
    local a, r, g, b = explode_argb(color)
    local ret = {a = a, r = r, g = g, b = b}
    function ret:apply_alpha(alpha)
        self.a = alpha
        return self
    end
    function ret:as_u32()
        return join_argb(self.a, self.b, self.g, self.r)
    end
    function ret:as_vec4()
        return imgui.ImVec4(self.r / 255, self.g / 255, self.b / 255, self.a / 255)
    end
    function ret:as_argb()
        return join_argb(self.a, self.r, self.g, self.b)
    end
    function ret:as_rgba()
        return join_argb(self.r, self.g, self.b, self.a)
    end
    function ret:as_chat()
        return string.format("%06X", ARGBtoRGB(join_argb(self.a, self.r, self.g, self.b)))
    end  
    return ret
end

if isMonetLoader() then


	local ffi = require('ffi')
	local gta = ffi.load('GTASA')
	ffi.cdef[[
		void _Z12AND_OpenLinkPKc(const char* link);
	]]

	function openLink(link)
		gta._Z12AND_OpenLinkPKc(link)
	end

	
end

function onScriptTerminate(script, game_quit)

    if script == thisScript() and not game_quit and not reset_settings_bool then
		
		sampAddChatMessage('[Hospital Helper] {ffffff}��������� ����������� ������, ������ ������������ ���� ������!', message_color)
		
		if not isMonetLoader() then 
			sampAddChatMessage('[Hospital Helper] {ffffff}����������� ' .. message_color_hex .. 'CTRL {ffffff}+ ' .. message_color_hex .. 'R {ffffff}����� ������������� ������.', message_color)
		end
		
		play_error_sound()
		
    end
	
end