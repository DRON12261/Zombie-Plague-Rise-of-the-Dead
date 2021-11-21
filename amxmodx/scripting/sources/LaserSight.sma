#include <amxmodx>
#include <amxmisc>

new sprite
new numwpns
new weapons[32]
new ls_enabled
new ls_line
new ls_pvis
new ls_wpns
new ls_rgb
new numteams
new rgb[3][4]

public plugin_init()
{
	register_plugin("Lasers", "0.5", "Toster v2.1")
	ls_enabled = register_cvar("ls_enabled", "1")
	ls_line = register_cvar("ls_line", "1")
	ls_pvis = register_cvar("ls_pvis", "2")
	ls_wpns = register_cvar("ls_wpns", "0;4;6;9;25;29;")
	ls_rgb = register_cvar("ls_rgb", "255 0 0")
	register_clcmd("ls_refresh", "getcvars", numwpns, 680, -1)
	register_clcmd("ls_getteam", "getteam", numwpns, 680, -1)
	register_clcmd("ls_getwpn", "getwpn", numwpns, 680, -1)
	getcvars();
	return 0;
}

public getwpn(id)
{
	new clip;
	new ammo;
	new w = get_user_weapon(id, clip, ammo);
	console_print(id, "[ls] Your current weapon's id: %d", w);
	return 1;
}

public getteam(id)
{
	new t = get_user_team(id, {0}, sprite);
	console_print(id, "[ls] Your current team's id: %d", t);
	return 1;
}

public getcvars()
{
	getwpns();
	getrgb();
	return 1;
}

public getrgb()
{
	new txt[64];
	new team[4][16] = {
		{
			32, 0, 59, 0, 32, 0, 59, 0, 115, 112, 114, 105, 116, 101, 115, 47
		},
		{
			119, 104, 105, 116, 101, 46, 115, 112, 114, 0, 0, 0, 0, 0, 0, 0
		},
		{
			0, ...
		},
		{
			0, ...
		}
	};
	new tmp[4];
	get_pcvar_string(ls_rgb, txt, 64);
	add(txt, 64, 1112, sprite);
	numteams = 0;
	while (contain(txt, 1120) != -1)
	{
		strtok(txt, team[numteams], 16, txt, 64, 59, sprite);
		new i;
		while (i < 2)
		{
			strtok(team[numteams], tmp, numwpns, team[numteams], 16, 32, sprite);
			rgb[i][numteams] = str_to_num(tmp);
			i++;
		}
		trim(team[numteams]);
		rgb[2][numteams] = str_to_num(team[numteams]);
		trim(txt);
		numteams += 1;
	}
	return 0;
}

public getwpns()
{
	new txt[64];
	new wpns[3];
	get_pcvar_string(ls_wpns, txt, 64);
	add(txt, 64, 1128, sprite);
	numwpns = 0;
	while (contain(txt, 1136) != -1)
	{
		strtok(txt, wpns, 3, txt, 64, 59, sprite);
		weapons[numwpns] = str_to_num(wpns);
		numwpns += 1;
	}
	return 0;
}

public plugin_precache()
{
	sprite = precache_model("sprites/white.spr");
	return 0;
}

public client_PreThink(id)
{
	new var1;
	if (!is_user_alive(id) || get_pcvar_num(ls_enabled) == 1)
	{
		return 1;
	}
	new clip;
	new ammo;
	new w = get_user_weapon(id, clip, ammo);
	new i;
	while (i < numwpns)
	{
		if (weapons[i] == w)
		{
			return 1;
		}
		i++;
	}
	new e[3];
	new t = get_user_team(id, {0}, sprite);
	get_user_origin(id, e, 3);
	if (get_pcvar_num(ls_pvis))
	{
		message_begin(weapons, 23, 1216, id);
	}
	else
	{
		message_begin(sprite, 23, 1216, sprite);
	}
	if (get_pcvar_num(ls_line))
	{
		write_byte(1);
		write_short(id | 4096);
		write_coord(e[0]);
		write_coord(e[1]);
		write_coord(e[2]);
	}
	else
	{
		write_byte(sprite);
		write_coord(e[0] + 1);
		write_coord(e[1] + 1);
		write_coord(e[2] + 1);
		write_coord(e[0] - 1);
		write_coord(e[1] - 1);
		write_coord(e[2] - 1);
	}
	write_short(sprite);
	write_byte(sprite);
	write_byte(10);
	write_byte(1);
	write_byte(5);
	write_byte(sprite);
	if (numteams >= t)
	{
		new var2 = rgb;
		write_byte(var2[0][var2][t + -1]);
		write_byte(rgb[1][t + -1]);
		write_byte(rgb[2][t + -1]);
	}
	else
	{
		new var3 = rgb;
		write_byte(var3[0][var3]);
		write_byte(rgb[1]);
		write_byte(rgb[2]);
	}
	write_byte(255);
	write_byte(10);
	message_end();
	return 1;
}