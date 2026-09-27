--[[
free ui by shitaro.lol t.me/shitaromake
меню делал на скорую руку, говно ебаное но +- под кс тему,багов по моему не оставлял
если ты получил данный сурс через хук реквеста - красава, мне похуй на уишку, так как такая се и защищать тут нечего, 
а так бы я мог поставить лураф спокойно, что и стоит в визуалах xd
]]--


local cr = cloneref or function(o) return o end
local prot = protect_gui or (syn and syn.protect_gui) or function() end

local players = cr(game:GetService("Players"))
local tws = cr(game:GetService("TweenService"))
local uis = cr(game:GetService("UserInputService"))
local guis = cr(game:GetService("GuiService"))
local runs = cr(game:GetService("RunService"))
local stats = cr(game:GetService("Stats"))
local coregui = cr(game:GetService("CoreGui"))

local lp = players.LocalPlayer

local pal = {
	bg = Color3.fromRGB(16, 16, 18),
	panel = Color3.fromRGB(18, 18, 21),
	group = Color3.fromRGB(22, 22, 26),
	raised = Color3.fromRGB(32, 32, 37),
	sunken = Color3.fromRGB(18, 18, 22),
	line = Color3.fromRGB(50, 50, 58),
	hair = Color3.fromRGB(35, 35, 41),
	edge = Color3.fromRGB(8, 8, 10),
	sel = Color3.fromRGB(255, 255, 255),
	txt = Color3.fromRGB(176, 176, 184),
	dim = Color3.fromRGB(104, 104, 114),
	accent = Color3.fromRGB(142, 176, 255),
	accent2 = Color3.fromRGB(52, 78, 152),
}

local fnt = Enum.Font.Code
local fnt_face
do
	local ok, face = pcall(function()
		return Font.fromEnum(fnt)
	end)
	if ok and face then
		fnt_face = face
	end
end
local ease = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local fade = TweenInfo.new(0.11, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
local slidein = TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

local ico = {
	rage = 83752373575368,
	antiaim = 97818595741565,
	legit = 121091323240554,
	visuals = 127234874352422,
	world = 125685532120024,
	skins = 128162112866809,
	misc = 109485777305919,
	players = 85332511060401,
	lua = 75851496262862,
	config = 122894934359450,
	folder = 77937190465422,
	chevron = 71457658246709,
	check = 86817768619372,
	gear = 106205298246017,
	dots = 95127553964880,
	trash = 126010725826757,
	resize = 111179404262244,
	wifi = 104941258142372,
	gauge = 128279962545721,
	ram = 82464660673318,
	clock = 136533241128438,
	shield = 106509993556171,
	crosshair = 83752373575368,
	target = 121091323240554,
	eye = 127234874352422,
	settings = 109485777305919,
	wrench = 85345725497834,
	zap = 109718589733073,
	palette = 127369887384101,
	keyboard = 121978468376124,
	sliders = 125396339381135,
	invalid = 109960743825561,
}

local cfg_dir = "shitaro/configs"

local b64set = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

local function chr(i)
	return b64set:sub(i + 1, i + 1)
end

local function b64enc(s)
	if crypt and crypt.base64encode then
		return crypt.base64encode(s)
	end
	local out, i = {}, 1
	while i <= #s do
		local a, b, c = s:byte(i, i + 2)
		local n = a * 65536 + (b or 0) * 256 + (c or 0)
		out[#out + 1] = chr(n // 262144 % 64)
			.. chr(n // 4096 % 64)
			.. (b and chr(n // 64 % 64) or "=")
			.. (c and chr(n % 64) or "=")
		i = i + 3
	end
	return table.concat(out)
end

local function b64dec(s)
	if crypt and crypt.base64decode then
		return crypt.base64decode(s)
	end
	local out, bits, nbits = {}, 0, 0
	for i = 1, #s do
		local v = b64set:find(s:sub(i, i), 1, true)
		if v then
			bits = bits * 64 + (v - 1)
			nbits = nbits + 6
			if nbits >= 8 then
				nbits = nbits - 8
				local d = 2 ^ nbits
				out[#out + 1] = string.char(bits // d % 256)
				bits = bits % d
			end
		end
	end
	return table.concat(out)
end

local function mk(cls, props, kids)
	local o = Instance.new(cls)
	local up
	if props then
		up = props.parent
		props.parent = nil
		for k, v in props do
			o[k] = v
		end
	end
	if kids then
		for _, k in kids do
			k.Parent = o
		end
	end
	o.Parent = up
	return o
end

local function corner(o, r)
	return mk("UICorner", { parent = o, CornerRadius = UDim.new(0, r or 5) })
end

local function outline(o, c, t)
	return mk("UIStroke", {
		parent = o,
		Color = c or pal.edge,
		Thickness = t or 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})
end

local function inset(o, l, t, r, b)
	return mk("UIPadding", {
		parent = o,
		PaddingLeft = UDim.new(0, l or 0),
		PaddingTop = UDim.new(0, t or l or 0),
		PaddingRight = UDim.new(0, r or l or 0),
		PaddingBottom = UDim.new(0, b or t or l or 0),
	})
end

local function stack(o, gap)
	return mk("UIListLayout", {
		parent = o,
		Padding = UDim.new(0, gap or 0),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
end

local function line(o, gap)
	return mk("UIListLayout", {
		parent = o,
		FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, gap or 0),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
end

local function shade(o, a, b, rot)
	return mk("UIGradient", {
		parent = o,
		Rotation = rot or 90,
		Color = ColorSequence.new(a, b),
	})
end

local function text(props)
	props.BackgroundTransparency = 1
	props.Font = props.Font or fnt
	if fnt_face then
		props.FontFace = props.FontFace or fnt_face
	end
	props.TextSize = props.TextSize or 12
	props.TextColor3 = props.TextColor3 or pal.txt
	props.TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left
	props.TextYAlignment = props.TextYAlignment or Enum.TextYAlignment.Center
	props.RichText = true
	return mk("TextLabel", props)
end

local function image(props)
	props.BackgroundTransparency = 1
	props.ScaleType = props.ScaleType or Enum.ScaleType.Fit
	return mk("ImageLabel", props)
end

local function asset(id)
	return "rbxassetid://" .. tostring(id)
end

local function divider(parent, y, clr, trim)
	local band = mk("Frame", {
		parent = parent,
		BackgroundColor3 = pal.edge,
		BorderSizePixel = 0,
		Size = UDim2.new(1, -(trim or 0), 0, 3),
		Position = UDim2.new(0, 0, 0, (y or 0) - 1),
	})
	mk("Frame", {
		parent = band,
		BackgroundColor3 = clr or pal.hair,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 0, 1),
	})
	return band
end

local function to(o, goal, info)
	local t = tws:Create(o, info or ease, goal)
	t:Play()
	return t
end

local function ring(o, r)
	corner(o, r)
	local stroke = outline(o, pal.edge)
	local inner = mk("Frame", {
		parent = o,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -2, 1, -2),
		Position = UDim2.fromOffset(1, 1),
		ZIndex = 20,
	})
	corner(inner, r - 1)
	outline(inner, pal.line)
	return inner, stroke
end

local function panel(parent, order, fill, r)
	r = r or 7
	local wrap = mk("Frame", {
		parent = parent,
		BackgroundColor3 = pal.edge,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = order,
	})
	corner(wrap, r)
	inset(wrap, 1)

	local mid = mk("Frame", {
		parent = wrap,
		BackgroundColor3 = pal.line,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
	})
	corner(mid, r - 1)
	inset(mid, 1)

	local box = mk("Frame", {
		parent = mid,
		BackgroundColor3 = fill or pal.group,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		ClipsDescendants = true,
	})
	corner(box, r - 2)
	return wrap, box
end

local function fader(root)
	local items = {}
	local function add(o)
		if o:IsA("UIStroke") then
			items[#items + 1] = { o = o, st = o.Transparency }
		elseif o:IsA("GuiObject") then
			local e = { o = o, bg = o.BackgroundTransparency }
			if o:IsA("TextLabel") or o:IsA("TextBox") or o:IsA("TextButton") then
				e.tx = o.TextTransparency
			end
			if o:IsA("ImageLabel") or o:IsA("ImageButton") then
				e.im = o.ImageTransparency
			end
			items[#items + 1] = e
		end
	end
	add(root)
	for _, c in root:GetDescendants() do
		add(c)
	end
	return function(a, instant)
		for _, e in items do
			local goal = {}
			if e.st then
				goal.Transparency = e.st + (1 - e.st) * a
			end
			if e.bg then
				goal.BackgroundTransparency = e.bg + (1 - e.bg) * a
			end
			if e.tx then
				goal.TextTransparency = e.tx + (1 - e.tx) * a
			end
			if e.im then
				goal.ImageTransparency = e.im + (1 - e.im) * a
			end
			if instant then
				for k, v in goal do
					e.o[k] = v
				end
			else
				to(e.o, goal, fade)
			end
		end
	end
end

local function plate(parent, axis, w, h, fill, canvas)
	local wide = axis == Enum.AutomaticSize.X
	local hull = mk(canvas and "CanvasGroup" or "Frame", {
		parent = parent,
		BackgroundColor3 = pal.edge,
		BorderSizePixel = 0,
		Size = wide and UDim2.fromOffset(0, h) or UDim2.fromOffset(w, 0),
		AutomaticSize = axis,
	})
	corner(hull, 7)
	inset(hull, 1)

	local band = mk("Frame", {
		parent = hull,
		BackgroundColor3 = pal.line,
		BorderSizePixel = 0,
		Size = wide and UDim2.new(0, 0, 1, 0) or UDim2.new(1, 0, 0, 0),
		AutomaticSize = axis,
	})
	corner(band, 6)
	inset(band, 1)

	local box = mk("Frame", {
		parent = band,
		BackgroundColor3 = fill or pal.panel,
		BorderSizePixel = 0,
		Size = wide and UDim2.new(0, 0, 1, 0) or UDim2.new(1, 0, 0, 0),
		AutomaticSize = axis,
		ClipsDescendants = true,
	})
	corner(box, 5)
	return hull, box
end

local function screen(name)
	local g = mk("ScreenGui", {
		Name = name,
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = 1000,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	})
	pcall(prot, g)
	g.Parent = (gethui and gethui()) or coregui
	return g
end

local conns = {}

local function hook(sig, fn)
	local c = sig:Connect(fn)
	table.insert(conns, c)
	return c
end

local step_tag = "sh_" .. tostring(math.random(1e5, 9e5))
local free_api, free_bound, hold_mode, hold_icon

local function find_free()
	local rs = cr(game:GetService("ReplicatedStorage"))
	local box = rs:FindFirstChild("Modules")
	local m = box and box:FindFirstChild("FreeMouse") or rs:FindFirstChild("FreeMouse", true)
	if not m or not m:IsA("ModuleScript") then
		return false
	end
	local ok, api = pcall(require, m)
	if ok and type(api) == "table" and api.SetFreeMouseEnabled then
		return api
	end
	return false
end

local function unlock(state)
	if free_api == nil then
		free_api = find_free()
	end
	if free_api then
		pcall(function()
			free_api:SetFreeMouseEnabled(step_tag, state or nil)
		end)
	end
	if state then
		if free_bound then
			return
		end
		hold_mode, hold_icon = uis.MouseBehavior, uis.MouseIconEnabled
		free_bound = true
		runs:BindToRenderStep(step_tag, Enum.RenderPriority.Last.Value, function()
			if uis.MouseBehavior ~= Enum.MouseBehavior.Default then
				uis.MouseBehavior = Enum.MouseBehavior.Default
			end
			if not uis.MouseIconEnabled then
				uis.MouseIconEnabled = true
			end
		end)
		return
	end
	if not free_bound then
		return
	end
	free_bound = false
	pcall(runs.UnbindFromRenderStep, runs, step_tag)
	if hold_mode then
		uis.MouseBehavior = hold_mode
		uis.MouseIconEnabled = hold_icon
		hold_mode = nil
	end
end

local function mouse()
	return uis:GetMouseLocation() - guis:GetGuiInset()
end

local function pointer(i)
	return i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch
end

local function moved(i)
	return i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch
end

local function grip(handle, frame, gate)
	local held, origin, base
	hook(handle.InputBegan, function(i)
		if not pointer(i) or (gate and not gate()) then
			return
		end
		held, origin, base = true, i.Position, frame.Position
	end)
	hook(uis.InputChanged, function(i)
		if not held or not moved(i) then
			return
		end
		local d = i.Position - origin
		frame.Position = UDim2.new(base.X.Scale, base.X.Offset + d.X, base.Y.Scale, base.Y.Offset + d.Y)
	end)
	hook(uis.InputEnded, function(i)
		if pointer(i) then
			held = false
		end
	end)
end

local function surface(parent, z)
	return mk("TextButton", {
		parent = parent,
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Text = "",
		ZIndex = z or 8,
		AutoButtonColor = false,
	})
end

local function drag(zone, fn)
	local held
	local hit = surface(zone)
	hook(hit.InputBegan, function(i)
		if not pointer(i) then
			return
		end
		held = true
		fn(mouse())
	end)
	hook(uis.InputChanged, function(i)
		if not held or not moved(i) then
			return
		end
		fn(mouse())
	end)
	hook(uis.InputEnded, function(i)
		if pointer(i) then
			held = false
		end
	end)
	return hit
end

local function hover(btn, on, off)
	btn.MouseEnter:Connect(on)
	btn.MouseLeave:Connect(off)
end

local function clamp01(v)
	return v < 0 and 0 or v > 1 and 1 or v
end

local function round(v, dec)
	local m = 10 ^ (dec or 0)
	return math.floor(v * m + 0.5) / m
end

local key_map = {
	MouseLeft = "m1",
	MouseRight = "m2",
	MouseMiddle = "m3",
	LeftShift = "lshift",
	RightShift = "rshift",
	LeftControl = "lctrl",
	RightControl = "rctrl",
	LeftAlt = "lalt",
	RightAlt = "ralt",
	CapsLock = "caps",
	Backspace = "bspace",
	Return = "enter",
	Space = "space",
	Insert = "ins",
	Delete = "del",
	PageUp = "pgup",
	PageDown = "pgdn",
	PrintScreen = "prtsc",
}

local function key_name(k)
	if not k then
		return "none"
	end
	if key_map[k] then
		return key_map[k]
	end
	local low = k:lower()
	return #low <= 6 and low or low:sub(1, 6)
end

local kb_modes = { "hold", "toggle", "always" }
local kb_short = { hold = "hld", toggle = "tgl", always = "alw" }

local binds = {}
local capture_fn
local bus_down, bus_up, bus_cap

local function bus()
	if bus_down then
		return
	end
	bus_cap = hook(uis.InputBegan, function(i)
		if not capture_fn then
			return
		end
		local k
		if i.UserInputType == Enum.UserInputType.Keyboard then
			k = i.KeyCode.Name
		elseif i.UserInputType == Enum.UserInputType.MouseButton2 then
			k = "MouseRight"
		elseif i.UserInputType == Enum.UserInputType.MouseButton3 then
			k = "MouseMiddle"
		elseif i.UserInputType == Enum.UserInputType.MouseButton1 then
			k = "cancel"
		end
		if not k then
			return
		end
		local fn = capture_fn
		capture_fn = nil
		fn(k)
	end)
	bus_down = hook(uis.InputBegan, function(i, busy)
		if busy or capture_fn then
			return
		end
		for _, b in binds do
			b.down(i)
		end
	end)
	bus_up = hook(uis.InputEnded, function(i)
		for _, b in binds do
			b.up(i)
		end
	end)
end

local function hits(i, key)
	return (i.UserInputType == Enum.UserInputType.Keyboard and i.KeyCode.Name == key)
		or (i.UserInputType == Enum.UserInputType.MouseButton2 and key == "MouseRight")
		or (i.UserInputType == Enum.UserInputType.MouseButton3 and key == "MouseMiddle")
end



local function make_bind(g, opts)
	local win = g.win
	local key, mode = nil, opts.mode or "toggle"
	local capturing, open, held, latched = false, false, false, false
	local entry, sync
	local wide = opts.value ~= nil
	local ph = wide and 90 or 54
	local pw = 186

	local pop = mk("Frame", {
		parent = win.layer,
		BackgroundColor3 = pal.group,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(pw, ph),
		Visible = false,
		ZIndex = 80,
	})
	ring(pop, 6)

	text({
		parent = pop,
		Text = "bind",
		TextSize = 11,
		TextColor3 = pal.dim,
		Size = UDim2.new(1, -16, 0, 12),
		Position = UDim2.fromOffset(8, 8),
	})

	local slot = mk("Frame", {
		parent = pop,
		BackgroundColor3 = pal.raised,
		BorderSizePixel = 0,
		Size = UDim2.new(1, -42, 0, 20),
		Position = UDim2.fromOffset(8, 26),
		ClipsDescendants = true,
	})
	ring(slot, 4)

	local cap = text({
		parent = slot,
		Text = "",
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.fromScale(1, 1),
	})

	local pick = surface(slot, 10)

	local wipe = mk("TextButton", {
		parent = pop,
		BackgroundColor3 = pal.raised,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(20, 20),
		Position = UDim2.new(1, -28, 0, 26),
		Text = "",
		ClipsDescendants = true,
		AutoButtonColor = false,
	})
	ring(wipe, 4)

	local can = image({
		parent = wipe,
		Image = asset(ico.trash),
		Size = UDim2.fromOffset(11, 11),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		ImageColor3 = pal.dim,
		ZIndex = 25,
	})

	if wide then
		local vc = opts.value

		text({
			parent = pop,
			Text = "value on active",
			TextSize = 11,
			TextColor3 = pal.dim,
			Size = UDim2.new(1, -70, 0, 12),
			Position = UDim2.fromOffset(8, 54),
		})

		local vnum = text({
			parent = pop,
			Text = "",
			TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Right,
			Size = UDim2.fromOffset(54, 12),
			Position = UDim2.new(1, -62, 0, 54),
		})

		local vzone = mk("Frame", {
			parent = pop,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -16, 0, 14),
			Position = UDim2.fromOffset(8, 68),
		})

		local vtrack = mk("Frame", {
			parent = vzone,
			BackgroundColor3 = pal.raised,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 6),
			Position = UDim2.new(0, 0, 0, 4),
			ClipsDescendants = true,
		})
		corner(vtrack, 3)
		outline(vtrack, pal.edge)

		local vfill = mk("Frame", {
			parent = vtrack,
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
			Size = UDim2.fromScale(0, 1),
		})
		corner(vfill, 3)
		shade(vfill, pal.accent2, pal.accent, 0)

		local vknob = mk("Frame", {
			parent = vzone,
			BackgroundColor3 = pal.sel,
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(3, 12),
			Position = UDim2.new(0, 0, 0, 7),
			AnchorPoint = Vector2.new(0.5, 0.5),
			ZIndex = 5,
		})
		corner(vknob, 2)
		outline(vknob, pal.edge)

		sync = function()
			local a = clamp01((vc.get() - vc.min) / (vc.max - vc.min))
			vfill.Size = UDim2.fromScale(a, 1)
			vknob.Position = UDim2.new(a, 0, 0, 7)
			vnum.Text = round(vc.get(), vc.dec) .. (vc.suffix or "")
		end

		local vhit = drag(vzone, function(p)
			local a = clamp01((p.X - vtrack.AbsolutePosition.X) / vtrack.AbsoluteSize.X)
			vc.set(vc.min + (vc.max - vc.min) * a)
			sync()
		end)

		hover(vhit, function()
			to(vnum, { TextColor3 = pal.sel })
		end, function()
			to(vnum, { TextColor3 = pal.txt })
		end)

		sync()
	end

	local function paint()
		if capturing then
			cap.Text = "..."
			cap.TextColor3 = pal.sel
		elseif key then
			cap.Text = ("%s <font color=\"#6b6b74\">%s</font>"):format(key_name(key), kb_short[mode])
			cap.TextColor3 = pal.txt
		else
			cap.Text = "unbound"
			cap.TextColor3 = pal.dim
		end
		opts.tag(key and (" <font color=\"#6b6b74\">[%s]</font>"):format(key_name(key)) or "")
	end

	local function state()
		if not key then
			return false
		end
		if mode == "always" then
			return true
		end
		if opts.is_active and mode == "toggle" then
			local ok, v = pcall(opts.is_active)
			if ok then
				return v and true or false
			end
		end
		if mode == "toggle" then
			return latched
		end
		return held
	end

	local function detach()
		if not entry then
			return
		end
		local i = table.find(binds, entry)
		if i then
			table.remove(binds, i)
		end
		entry = nil
		held, latched = false, false
	end

	local function attach()
		if entry then
			return
		end
		bus()
		entry = {
			down = function(i)
				if not key or not hits(i, key) then
					return
				end
				held = true
				if mode == "toggle" then
					if opts.is_active then
						local ok, cur = pcall(opts.is_active)
						local nextv = not (ok and cur)
						latched = nextv
						opts.act(nextv)
					else
						latched = not latched
						opts.act(latched)
					end
				else
					opts.act(state())
				end
			end,
			up = function(i)
				if not held or not key or not hits(i, key) then
					return
				end
				held = false
				if mode == "hold" then
					opts.act(state())
				end
			end,
		}
		table.insert(binds, entry)
	end

	local function set(k, m, quiet)
		local shifted = (m ~= nil and m ~= mode) or (key ~= nil and k == nil)
		key = k
		mode = m or mode
		held, latched = false, false
		if key then
			attach()
		else
			detach()
		end
		paint()
		if quiet then
			return
		end
		if opts.changed then
			opts.changed(key, mode)
		end
		if shifted then
			opts.act(state())
		end
	end

	local fx = fader(pop)

	local function shut()
		if not open then
			return
		end
		open, capturing, capture_fn = false, false, nil
		paint()
		win:sync_scrim()
		fx(1)
		task.delay(0.14, function()
			if not open then
				pop.Visible = false
			end
		end)
	end

	local function show()
		win:close_popups()
		open = true
		win:place(pop, opts.anchor, pw, ph)
		paint()
		if sync then
			sync()
		end
		pop.Visible = true
		win:sync_scrim()
		fx(1, true)
		fx(0)
	end

	hover(pick, function()
		if not capturing then
			to(cap, { TextColor3 = pal.sel })
		end
	end, function()
		if not capturing then
			to(cap, { TextColor3 = key and pal.txt or pal.dim })
		end
	end)

	pick.MouseButton1Click:Connect(function()
		bus()
		capturing = true
		paint()
		capture_fn = function(k)
			capturing = false
			if k == "cancel" or k == "Escape" then
				paint()
			elseif k == "Backspace" then
				set(nil, nil)
			else
				set(k, nil)
			end
		end
	end)

	pick.MouseButton2Click:Connect(function()
		if capturing or not key then
			return
		end
		local i = table.find(kb_modes, mode) or 1
		set(key, kb_modes[i % #kb_modes + 1])
	end)

	hover(wipe, function()
		to(can, { ImageColor3 = pal.sel })
	end, function()
		to(can, { ImageColor3 = pal.dim })
	end)

	wipe.MouseButton1Click:Connect(function()
		set(nil, nil)
	end)

	for _, t in opts.triggers do
		t.MouseButton2Click:Connect(show)
	end

	win:reg_popup(shut, function()
		return open
	end)
	paint()

	if opts.flag then
		g:_bind(opts.flag, "key", function()
			return { key = key, mode = mode }
		end, function(v)
			set(v.key, v.mode, true)
		end)
	end

	win:hk_register({
		name = opts.name or "bind",
		info = opts.info,
		bound = function()
			return key ~= nil
		end,
		state = function()
			return state(), mode, key
		end,
	})

	return { active = state }
end

local hue_seq = ColorSequence.new({
	ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
	ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
	ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
	ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)),
	ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
	ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
	ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0)),
})

local function make_picker(g, host, cfg, right)
	local win = g.win
	local base = cfg.default or Color3.fromRGB(235, 235, 240)
	local h, s, v = base:ToHSV()
	local a = cfg.alpha or 1
	local open = false
	local pw, ph = 180, 165

	local hull = mk("Frame", {
		parent = host,
		BackgroundColor3 = pal.edge,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(26, 16),
		Position = UDim2.new(1, -right, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
	})
	corner(hull, 5)
	inset(hull, 1)

	local band = mk("Frame", {
		parent = hull,
		BackgroundColor3 = pal.line,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
	})
	corner(band, 4)
	inset(band, 1)

	local swatch = mk("TextButton", {
		parent = band,
		BackgroundColor3 = base,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		Text = "",
		AutoButtonColor = false,
	})
	corner(swatch, 3)

	local pop = mk("Frame", {
		parent = win.layer,
		BackgroundColor3 = pal.group,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(pw, ph),
		Visible = false,
		ZIndex = 70,
	})
	ring(pop, 6)

	local sv = mk("Frame", {
		parent = pop,
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(168, 104),
		Position = UDim2.fromOffset(6, 6),
	})
	corner(sv, 4)

	local tint = mk("UIGradient", { parent = sv })

	local dark = mk("Frame", {
		parent = sv,
		BackgroundColor3 = Color3.new(),
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
	})
	corner(dark, 4)
	mk("UIGradient", {
		parent = dark,
		Rotation = 90,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(1, 0),
		}),
	})

	local dot = mk("Frame", {
		parent = pop,
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(7, 7),
		AnchorPoint = Vector2.new(0.5, 0.5),
		ZIndex = 4,
	})
	corner(dot, 4)
	outline(dot, pal.sel, 1.5)

	local hue = mk("Frame", {
		parent = pop,
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(168, 8),
		Position = UDim2.fromOffset(6, 115),
	})
	corner(hue, 3)
	mk("UIGradient", { parent = hue, Color = hue_seq })

	local hknob = mk("Frame", {
		parent = hue,
		BackgroundColor3 = pal.sel,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 3, 1, 2),
		Position = UDim2.new(0, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		ZIndex = 3,
	})
	corner(hknob, 2)
	outline(hknob, pal.edge)

	local abase = mk("Frame", {
		parent = pop,
		BackgroundColor3 = pal.raised,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(168, 8),
		Position = UDim2.fromOffset(6, 127),
	})
	corner(abase, 3)

	local afill = mk("Frame", {
		parent = abase,
		BackgroundColor3 = base,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
	})
	corner(afill, 3)
	mk("UIGradient", {
		parent = afill,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(1, 0),
		}),
	})

	local aknob = mk("Frame", {
		parent = abase,
		BackgroundColor3 = pal.sel,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 3, 1, 2),
		Position = UDim2.new(0, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		ZIndex = 3,
	})
	corner(aknob, 2)
	outline(aknob, pal.edge)

	local field = mk("Frame", {
		parent = pop,
		BackgroundColor3 = pal.raised,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(168, 18),
		Position = UDim2.fromOffset(6, 141),
		ClipsDescendants = true,
	})
	ring(field, 4)

	local hex = mk("TextBox", {
		parent = field,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -14, 1, 0),
		Position = UDim2.fromOffset(7, 0),
		Font = fnt,
		FontFace = fnt_face,
		TextSize = 11,
		TextColor3 = pal.txt,
		Text = "",
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false,
	})

	local function color()
		return Color3.fromHSV(h, s, v)
	end

	local function paint()
		local c = color()
		swatch.BackgroundColor3 = c
		swatch.BackgroundTransparency = 1 - a
		tint.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromHSV(h, 1, 1))
		afill.BackgroundColor3 = c
		dot.Position = UDim2.fromOffset(6 + s * 168, 6 + (1 - v) * 104)
		hknob.Position = UDim2.new(h, 0, 0.5, 0)
		aknob.Position = UDim2.new(a, 0, 0.5, 0)
		if not hex:IsFocused() then
			hex.Text = ("#%02x%02x%02x"):format(
				math.floor(c.R * 255 + 0.5),
				math.floor(c.G * 255 + 0.5),
				math.floor(c.B * 255 + 0.5)
			)
		end
	end

	local function fire()
		if cfg.on then
			cfg.on(color(), a)
		end
	end

	local function set(c, na, quiet)
		h, s, v = c:ToHSV()
		a = na or a
		paint()
		if not quiet then
			fire()
		end
	end

	drag(sv, function(p)
		s = clamp01((p.X - sv.AbsolutePosition.X) / sv.AbsoluteSize.X)
		v = 1 - clamp01((p.Y - sv.AbsolutePosition.Y) / sv.AbsoluteSize.Y)
		paint()
		fire()
	end)

	drag(hue, function(p)
		h = clamp01((p.X - hue.AbsolutePosition.X) / hue.AbsoluteSize.X)
		paint()
		fire()
	end)

	drag(abase, function(p)
		a = clamp01((p.X - abase.AbsolutePosition.X) / abase.AbsoluteSize.X)
		paint()
		fire()
	end)

	hex.FocusLost:Connect(function()
		local raw = hex.Text:gsub("#", "")
		local n = tonumber(raw, 16)
		if n and #raw == 6 then
			set(Color3.fromRGB(n // 65536 % 256, n // 256 % 256, n % 256), nil)
		else
			paint()
		end
	end)

	local fx = fader(pop)

	local function shut()
		if not open then
			return
		end
		open = false
		win:sync_scrim()
		fx(1)
		task.delay(0.14, function()
			if not open then
				pop.Visible = false
			end
		end)
	end

	swatch.MouseButton1Click:Connect(function()
		if open then
			shut()
			return
		end
		win:close_popups()
		open = true
		win:place(pop, hull, pw, ph, "right")
		pop.Visible = true
		win:sync_scrim()
		fx(1, true)
		fx(0)
	end)

	win:reg_popup(shut, function()
		return open
	end)
	paint()

	g:_bind(cfg.flag, "color", function()
		return { c = color(), a = a }
	end, function(val)
		set(val.c, val.a, true)
	end)

	return {
		get = function()
			return color(), a
		end,
		set = function(_, c, na)
			set(c, na)
		end,
	}
end

local grp = {}
grp.__index = grp

local function make_sheet(g, cfg, anchor, gear)
	local win = g.win
	local pw = cfg.width or 214
	local open = false

	local hull, box = plate(win.layer, Enum.AutomaticSize.Y, pw, 0, pal.group, true)
	hull.Visible = false
	hull.GroupTransparency = 1
	hull.ZIndex = 65

	stack(box, 0)

	local head = mk("Frame", {
		parent = box,
		BackgroundColor3 = pal.panel,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 24),
		LayoutOrder = 1,
	})
	corner(head, 5)
	mk("Frame", {
		parent = head,
		BackgroundColor3 = pal.panel,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 8),
		Position = UDim2.new(0, 0, 1, -8),
	})
	text({
		parent = head,
		Text = cfg.name or "options",
		TextColor3 = pal.txt,
		Size = UDim2.new(1, -20, 1, 0),
		Position = UDim2.new(0, 10, 0, 0),
		ZIndex = 2,
	})
	divider(head, 22, pal.line).ZIndex = 3

	local hold = mk("Frame", {
		parent = box,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 2,
	})
	inset(hold, 10, 9, 10, 10)

	local body = mk("Frame", {
		parent = hold,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
	})
	stack(body, 7)

	local function shut()
		if not open then
			return
		end
		open = false
		win:sync_scrim()
		to(gear, { ImageColor3 = pal.dim })
		to(hull, { GroupTransparency = 1 }, fade)
		task.delay(0.14, function()
			if not open then
				hull.Visible = false
			end
		end)
	end

	local function show()
		win:close_popups(true)
		open = true
		win:place(hull, anchor, pw, hull.AbsoluteSize.Y)
		hull.GroupTransparency = 1
		hull.Visible = true
		win:sync_scrim()
		to(hull, { GroupTransparency = 0 }, fade)
		to(gear, { ImageColor3 = pal.sel })
		task.defer(function()
			if open then
				win:place(hull, anchor, pw, hull.AbsoluteSize.Y)
			end
		end)
	end

	hover(gear, function()
		if not open then
			to(gear, { ImageColor3 = pal.txt })
		end
	end, function()
		if not open then
			to(gear, { ImageColor3 = pal.dim })
		end
	end)

	gear.MouseButton1Click:Connect(function()
		if open then
			shut()
		else
			show()
		end
	end)

	win:reg_popup(shut, function()
		return open
	end, true)

	return setmetatable({ win = win, tab = g.tab, body = body, frame = hull, n = 0 }, grp)
end

function grp:_row(h)
	self.n = self.n + 1
	return mk("Frame", {
		parent = self.body,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, h),
		LayoutOrder = self.n,
	})
end

function grp:_bind(flag, kind, get, set)
	if not flag then
		return
	end
	self.win.items[flag] = { kind = kind, get = get, set = set }
end

function grp:label(str)
	local r = self:_row(14)
	local l = text({
		parent = r,
		Text = str,
		TextColor3 = pal.dim,
		TextSize = 11,
		Size = UDim2.fromScale(1, 1),
		TextWrapped = true,
	})
	return {
		set = function(_, v)
			l.Text = v
		end,
	}
end

function grp:separator()
	local r = self:_row(5)
	divider(r, 2)
end

function grp:toggle(cfg)
	local r = self:_row(20)
	local state = cfg.default or false
	local base = cfg.name or "toggle"
	local tag = ""
	local picks = cfg.colors or {}
	local pad = cfg.options and 20 or 0

	local hull = mk("Frame", {
		parent = r,
		BackgroundColor3 = pal.edge,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(19, 19),
		Position = UDim2.new(0, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
	})
	corner(hull, 5)
	inset(hull, 1)

	local band = mk("Frame", {
		parent = hull,
		BackgroundColor3 = pal.line,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
	})
	corner(band, 4)
	inset(band, 1)

	local box = mk("Frame", {
		parent = band,
		BackgroundColor3 = pal.sunken,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		ClipsDescendants = true,
	})
	corner(box, 3)

	local glow = mk("Frame", {
		parent = box,
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 1,
	})
	corner(glow, 3)
	shade(glow, pal.accent, pal.accent2, 90)

	local tick = image({
		parent = box,
		Image = asset(ico.check),
		Size = UDim2.fromOffset(12, 12),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		ImageColor3 = pal.bg,
		ImageTransparency = 1,
		ZIndex = 2,
	})

	local lbl = text({
		parent = r,
		Text = base,
		TextColor3 = pal.dim,
		Size = UDim2.new(1, -27 - #picks * 30 - pad, 0, 14),
		Position = UDim2.new(0, 27, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
	})

	local hit = mk("TextButton", {
		parent = r,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -#picks * 30 - pad, 1, 0),
		Text = "",
		AutoButtonColor = false,
	})

	local function paint()
		to(glow, { BackgroundTransparency = state and 0 or 1 })
		to(tick, { ImageTransparency = state and 0 or 1 })
		to(lbl, { TextColor3 = state and pal.sel or pal.dim })
	end

	local function set(v, quiet)
		state = v and true or false
		paint()
		if not quiet and cfg.on then
			cfg.on(state)
		end
	end

	hover(hit, function()
		if not state then
			to(lbl, { TextColor3 = pal.txt })
		end
	end, function()
		if not state then
			to(lbl, { TextColor3 = pal.dim })
		end
	end)

	hit.MouseButton1Click:Connect(function()
		set(not state)
	end)

	paint()
	self:_bind(cfg.flag, "bool", function()
		return state
	end, function(v)
		set(v, true)
	end)

	make_bind(self, {
		anchor = r,
		triggers = { hit },
		flag = cfg.bind or (cfg.flag and cfg.flag .. ".bind"),
		name = base,
		mode = "toggle",
		is_active = function()
			return state
		end,
		act = function(a)
			set(a)
		end,
		tag = function(s)
			tag = s
			lbl.Text = base .. tag
		end,
	})

	local sheet
	if cfg.options then
		local gear = mk("ImageButton", {
			parent = r,
			BackgroundTransparency = 1,
			Image = asset(cfg.options == "dots" and ico.dots or ico.gear),
			ImageColor3 = pal.dim,
			Size = UDim2.fromOffset(14, 14),
			Position = UDim2.new(1, -15, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			AutoButtonColor = false,
		})
		sheet = make_sheet(self, cfg, r, gear)
	end

	local colors = {}
	for i = 1, math.min(#picks, 2) do
		colors[i] = make_picker(self, r, picks[i], 26 + pad + (i - 1) * 30)
	end

	return {
		get = function()
			return state
		end,
		set = function(_, v)
			set(v)
		end,
		colors = colors,
		options = sheet,
	}
end

function grp:slider(cfg)
	local r = self:_row(30)
	local min, max = cfg.min or 0, cfg.max or 100
	local dec = cfg.decimals or 0
	local suffix = cfg.suffix or ""
	local value = cfg.default or min
	local base = cfg.name or "slider"
	local tag = ""
	local target = cfg.bind_value or max
	local saved

	local lbl = text({
		parent = r,
		Text = base,
		TextColor3 = pal.dim,
		Size = UDim2.new(1, -54, 0, 14),
	})
	local val = text({
		parent = r,
		Text = "",
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Right,
		Size = UDim2.new(0, 54, 0, 14),
		Position = UDim2.new(1, -54, 0, 0),
	})

	local zone = mk("Frame", {
		parent = r,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 14),
		Position = UDim2.new(0, 0, 0, 16),
	})

	local track = mk("Frame", {
		parent = zone,
		BackgroundColor3 = pal.raised,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 6),
		Position = UDim2.new(0, 0, 0, 4),
		ClipsDescendants = true,
	})
	corner(track, 3)
	outline(track, pal.edge)

	local fill = mk("Frame", {
		parent = track,
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		Size = UDim2.fromScale(0, 1),
	})
	corner(fill, 3)
	shade(fill, pal.accent2, pal.accent, 0)

	local knob = mk("Frame", {
		parent = zone,
		BackgroundColor3 = pal.sel,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(3, 12),
		Position = UDim2.new(0, 0, 0, 7),
		AnchorPoint = Vector2.new(0.5, 0.5),
		ZIndex = 5,
	})
	corner(knob, 2)
	outline(knob, pal.edge)

	local function paint(instant)
		local a = clamp01((value - min) / (max - min))
		if instant then
			fill.Size = UDim2.fromScale(a, 1)
			knob.Position = UDim2.new(a, 0, 0, 7)
		else
			to(fill, { Size = UDim2.fromScale(a, 1) })
			to(knob, { Position = UDim2.new(a, 0, 0, 7) })
		end
		val.Text = round(value, dec) .. suffix
	end

	local function set(v, quiet, instant)
		v = round(math.clamp(v, min, max), dec)
		if v == value then
			paint(instant)
			return
		end
		value = v
		paint(instant)
		if not quiet and cfg.on then
			cfg.on(value)
		end
	end

	local hit = drag(zone, function(p)
		local a = (p.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
		set(min + (max - min) * clamp01(a), false, true)
	end)

	local catch = surface(r, 0)

	hover(hit, function()
		to(lbl, { TextColor3 = pal.txt })
		to(val, { TextColor3 = pal.sel })
	end, function()
		to(lbl, { TextColor3 = pal.dim })
		to(val, { TextColor3 = pal.txt })
	end)

	paint(true)
	self:_bind(cfg.flag, "number", function()
		return value
	end, function(v)
		set(tonumber(v) or min, true, true)
	end)

	local flag = cfg.bind or (cfg.flag and cfg.flag .. ".bind")
	if flag then
		self:_bind(flag .. "_value", "number", function()
			return target
		end, function(v)
			target = round(math.clamp(tonumber(v) or max, min, max), dec)
		end)
	end

	local bind = make_bind(self, {
		anchor = r,
		triggers = { hit, catch },
		flag = flag,
		name = base,
		mode = "hold",
		info = function(a)
			return round(a and target or value, dec) .. suffix
		end,
		act = function(a)
			if a then
				saved = value
				set(target)
			elseif saved ~= nil then
				set(saved)
				saved = nil
			end
			if cfg.on_bind then
				cfg.on_bind(a)
			end
		end,
		value = {
			min = min,
			max = max,
			dec = dec,
			suffix = suffix,
			get = function()
				return target
			end,
			set = function(v)
				target = round(math.clamp(tonumber(v) or target, min, max), dec)
			end,
		},
		tag = function(s)
			tag = s
			lbl.Text = base .. tag
		end,
	})

	return {
		get = function()
			return value
		end,
		set = function(_, v)
			set(v)
		end,
		active = bind.active,
	}
end

function grp:button(cfg)
	local r = self:_row(22)
	local base = cfg.name or "button"
	local tag = ""

	local btn = mk("TextButton", {
		parent = r,
		BackgroundColor3 = pal.panel,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		Text = "",
		ClipsDescendants = true,
		AutoButtonColor = false,
	})
	ring(btn, 5)

	local bar = mk("Frame", {
		parent = btn,
		BackgroundColor3 = pal.line,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 2, 1, -10),
		Position = UDim2.new(0, 2, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		ZIndex = 25,
	})

	local lbl = text({
		parent = btn,
		Text = base,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.new(1, -22, 0, 14),
		Position = UDim2.new(0, 11, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
	})

	local function fire()
		if cfg.on then
			cfg.on()
		end
	end

	hover(btn, function()
		to(lbl, { TextColor3 = pal.sel })
	end, function()
		to(lbl, { TextColor3 = pal.txt })
	end)

	btn.MouseButton1Down:Connect(function()
		lbl.TextColor3 = pal.dim
	end)
	btn.MouseButton1Up:Connect(function()
		to(lbl, { TextColor3 = pal.sel })
	end)
	btn.MouseButton1Click:Connect(fire)

	local bind = make_bind(self, {
		anchor = r,
		triggers = { btn },
		flag = cfg.bind or (cfg.flag and cfg.flag .. ".bind"),
		name = base,
		mode = "hold",
		act = function(a)
			if a then
				fire()
			end
		end,
		changed = cfg.on_bind,
		tag = function(s)
			tag = s
			lbl.Text = base .. tag
		end,
	})

	return { instance = btn, active = bind.active }
end

function grp:colorpicker(cfg)
	local r = self:_row(18)

	text({
		parent = r,
		Text = cfg.name or "color",
		TextColor3 = pal.dim,
		Size = UDim2.new(1, -32, 0, 14),
		Position = UDim2.new(0, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
	})

	return make_picker(self, r, cfg, 26)
end

function grp:keyfield(cfg)
	local r = self:_row(18)
	local key = cfg.default
	local capturing = false

	text({
		parent = r,
		Text = cfg.name or "key",
		TextColor3 = pal.dim,
		Size = UDim2.new(1, -86, 0, 14),
		Position = UDim2.new(0, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
	})

	local slot = mk("Frame", {
		parent = r,
		BackgroundColor3 = pal.raised,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(82, 16),
		Position = UDim2.new(1, -82, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		ClipsDescendants = true,
	})
	ring(slot, 4)

	local cap = text({
		parent = slot,
		Text = "",
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.fromScale(1, 1),
	})

	local pick = surface(slot, 10)

	local function paint()
		if capturing then
			cap.Text = "..."
			cap.TextColor3 = pal.sel
		else
			cap.Text = key_name(key)
			cap.TextColor3 = key and pal.txt or pal.dim
		end
	end

	local function set(k, quiet)
		key = k
		paint()
		if not quiet and cfg.on then
			cfg.on(key)
		end
	end

	hover(pick, function()
		if not capturing then
			to(cap, { TextColor3 = pal.sel })
		end
	end, function()
		if not capturing then
			to(cap, { TextColor3 = key and pal.txt or pal.dim })
		end
	end)

	pick.MouseButton1Click:Connect(function()
		bus()
		capturing = true
		paint()
		capture_fn = function(k)
			capturing = false
			if k == "cancel" or k == "Escape" then
				paint()
			elseif k == "Backspace" then
				set(nil)
			else
				set(k)
			end
		end
	end)

	paint()
	self:_bind(cfg.flag, "key", function()
		return { key = key, mode = "always" }
	end, function(v)
		set(v.key, true)
	end)

	return {
		get = function()
			return key
		end,
		set = function(_, k)
			set(k)
		end,
	}
end

function grp:textbox(cfg)
	local r = self:_row(cfg.name and 36 or 20)
	local value = cfg.default or ""

	if cfg.name then
		text({
			parent = r,
			Text = cfg.name,
			TextColor3 = pal.dim,
			Size = UDim2.new(1, 0, 0, 14),
			Position = UDim2.fromOffset(0, -3),
		})
	end

	local shell = mk("Frame", {
		parent = r,
		BackgroundColor3 = pal.raised,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 20),
		Position = UDim2.new(0, 0, 1, -20),
		ClipsDescendants = true,
	})
	ring(shell, 5)

	local field = mk("TextBox", {
		parent = shell,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -16, 1, 0),
		Position = UDim2.fromOffset(8, 0),
		Font = fnt,
		FontFace = fnt_face,
		TextSize = 12,
		TextColor3 = pal.txt,
		PlaceholderText = cfg.hint or "",
		PlaceholderColor3 = pal.dim,
		Text = value,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false,
	})

	field.Focused:Connect(function()
		to(field, { TextColor3 = pal.sel })
	end)
	field.FocusLost:Connect(function()
		to(field, { TextColor3 = pal.txt })
		value = field.Text
		if cfg.on then
			cfg.on(value)
		end
	end)
	field:GetPropertyChangedSignal("Text"):Connect(function()
		value = field.Text
	end)

	self:_bind(cfg.flag, "string", function()
		return field.Text
	end, function(v)
		value = tostring(v)
		field.Text = value
	end)

	return {
		get = function()
			return field.Text
		end,
		set = function(_, v)
			value = tostring(v)
			field.Text = value
		end,
	}
end

function grp:dropdown(cfg)
	local r = self:_row(cfg.name and 36 or 20)
	local list = cfg.options or {}
	local multi = cfg.multi or false
	local chosen = multi and (cfg.default or {}) or (cfg.default or list[1])
	local open = false
	local rows = {}
	local fx

	if cfg.name then
		text({
			parent = r,
			Text = cfg.name,
			TextColor3 = pal.dim,
			Size = UDim2.new(1, 0, 0, 14),
			Position = UDim2.fromOffset(0, -3),
		})
	end

	local box = mk("TextButton", {
		parent = r,
		BackgroundColor3 = pal.raised,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 20),
		Position = UDim2.new(0, 0, 1, -20),
		Text = "",
		ClipsDescendants = true,
		AutoButtonColor = false,
	})
	ring(box, 5)

	local cur = text({
		parent = box,
		Text = "",
		TextTruncate = Enum.TextTruncate.AtEnd,
		Size = UDim2.new(1, -30, 1, 0),
		Position = UDim2.new(0, 8, 0, 0),
	})

	local arrow = image({
		parent = box,
		Image = asset(ico.chevron),
		Size = UDim2.fromOffset(12, 12),
		Position = UDim2.new(1, -19, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		ImageColor3 = pal.dim,
	})

	local pop = mk("Frame", {
		parent = self.win.layer,
		BackgroundColor3 = pal.group,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(10, 10),
		Visible = false,
		ZIndex = 75,
		ClipsDescendants = true,
	})
	ring(pop, 5)

	local feed = mk("ScrollingFrame", {
		parent = pop,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, -10, 1, -10),
		Position = UDim2.fromOffset(5, 5),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 0,
		ScrollingDirection = Enum.ScrollingDirection.Y,
	})
	stack(feed, 1)

	local function caption()
		if multi then
			return #chosen == 0 and "none" or table.concat(chosen, ", ")
		end
		return tostring(chosen or "none")
	end

	local function picked(v)
		if not multi then
			return chosen == v
		end
		return table.find(chosen, v) ~= nil
	end

	local function paint()
		cur.Text = caption()
		local filled = multi and #chosen > 0 or (not multi and chosen ~= nil)
		to(cur, { TextColor3 = filled and pal.txt or pal.dim })
		for v, item in rows do
			to(item.lbl, { TextColor3 = picked(v) and pal.sel or pal.dim })
			to(item.mark, { BackgroundTransparency = picked(v) and 0 or 1 })
		end
	end

	local function shut()
		if not open then
			return
		end
		open = false
		self.win:sync_scrim()
		to(arrow, { Rotation = 0, ImageColor3 = pal.dim })
		if fx then
			fx(1)
		end
		task.delay(0.14, function()
			if not open then
				pop.Visible = false
			end
		end)
	end

	local function set(v, quiet)
		chosen = v
		paint()
		if not quiet and cfg.on then
			cfg.on(chosen)
		end
	end

	local function choose(v)
		if multi then
			local i = table.find(chosen, v)
			if i then
				table.remove(chosen, i)
			else
				table.insert(chosen, v)
			end
			set(chosen)
		else
			set(v)
			shut()
		end
	end

	local function build()
		if fx then
			fx(0, true)
		end
		for _, c in feed:GetChildren() do
			if c:IsA("GuiObject") then
				c:Destroy()
			end
		end
		table.clear(rows)
		for i, v in list do
			local item = mk("Frame", {
				parent = feed,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 19),
				LayoutOrder = i,
			})
			local mark = mk("Frame", {
				parent = item,
				BackgroundColor3 = pal.sel,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(0, 2, 0, 11),
				Position = UDim2.new(0, 0, 0.5, 0),
				AnchorPoint = Vector2.new(0, 0.5),
			})
			local lbl = text({
				parent = item,
				Text = tostring(v),
				TextColor3 = pal.dim,
				Size = UDim2.new(1, -16, 1, 0),
				Position = UDim2.new(0, 9, 0, 0),
			})
			local hit = surface(item, 4)
			hover(hit, function()
				if not picked(v) then
					to(lbl, { TextColor3 = pal.txt })
				end
			end, function()
				if not picked(v) then
					to(lbl, { TextColor3 = pal.dim })
				end
			end)
			hit.MouseButton1Click:Connect(function()
				choose(v)
			end)
			rows[v] = { frame = item, lbl = lbl, mark = mark }
		end
		fx = fader(pop)
	end

	build()

	local function show()
		self.win:close_popups()
		if cfg.on_open then
			cfg.on_open()
		end
		open = true
		local h = math.min(#list, 8) * 20 + 10
		local w = box.AbsoluteSize.X
		pop.Size = UDim2.fromOffset(w, h)
		self.win:place(pop, box, w, h)
		pop.Visible = true
		self.win:sync_scrim()
		fx(1, true)
		fx(0)
		to(arrow, { Rotation = 180, ImageColor3 = pal.sel })
	end

	hover(box, function()
		if not open then
			to(cur, { TextColor3 = pal.sel })
		end
	end, function()
		if not open then
			paint()
		end
	end)

	box.MouseButton1Click:Connect(function()
		if open then
			shut()
		else
			show()
		end
	end)

	self.win:reg_popup(shut, function()
		return open
	end)

	paint()
	self:_bind(cfg.flag, multi and "list" or "string", function()
		return chosen
	end, function(v)
		set(v, true)
	end)

	return {
		get = function()
			return chosen
		end,
		set = function(_, v)
			set(v)
		end,
		opened = function()
			return open
		end,
		reload = function(_, options)
			list = options or {}
			build()
			if not multi and not table.find(list, chosen) then
				chosen = list[1]
			end
			paint()
			if open then
				local h = math.min(#list, 8) * 20 + 10
				pop.Size = UDim2.fromOffset(box.AbsoluteSize.X, h)
				self.win:place(pop, box, box.AbsoluteSize.X, h)
			end
		end,
	}
end

local function split(s, sep)
	local out = {}
	for part in (s .. sep):gmatch("(.-)" .. sep) do
		out[#out + 1] = part
	end
	return out
end

local function encode(kind, v)
	if kind == "bool" then
		return v and "1" or "0"
	elseif kind == "number" then
		return tostring(v)
	elseif kind == "list" then
		return table.concat(v, "\3")
	elseif kind == "key" then
		return (v.key or "none") .. "\3" .. v.mode
	elseif kind == "color" then
		return ("%d\3%d\3%d\3%.4f"):format(
			math.floor(v.c.R * 255 + 0.5),
			math.floor(v.c.G * 255 + 0.5),
			math.floor(v.c.B * 255 + 0.5),
			v.a
		)
	end
	return tostring(v)
end

local function decode(kind, raw)
	if kind == "bool" then
		return raw == "1"
	elseif kind == "number" then
		return tonumber(raw) or 0
	elseif kind == "list" then
		return raw == "" and {} or split(raw, "\3")
	elseif kind == "key" then
		local p = split(raw, "\3")
		return { key = p[1] ~= "none" and p[1] or nil, mode = p[2] or "hold" }
	elseif kind == "color" then
		local p = split(raw, "\3")
		return {
			c = Color3.fromRGB(tonumber(p[1]) or 0, tonumber(p[2]) or 0, tonumber(p[3]) or 0),
			a = tonumber(p[4]) or 1,
		}
	end
	return raw
end

local tabm = {}
tabm.__index = tabm

function tabm:_pair()
	if self.pair then
		return self.pair
	end
	self.order = self.order + 1

	local row = mk("Frame", {
		parent = self.page,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = self.order,
	})

	local function col(x)
		local c = mk("Frame", {
			parent = row,
			BackgroundTransparency = 1,
			Size = UDim2.new(0.5, -5, 0, 0),
			Position = UDim2.new(x, x == 0 and 0 or 5, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
		})
		stack(c, 10)
		return c
	end

	self.pair = { left = col(0), right = col(0.5), ln = 0, rn = 0 }
	return self.pair
end

function tabm:group(name, side)
	local host, order

	if side == "full" then
		self.pair = nil
		self.order = self.order + 1
		host, order = self.page, self.order
	else
		local p = self:_pair()
		if side == "right" then
			p.rn = p.rn + 1
			host, order = p.right, p.rn
		else
			p.ln = p.ln + 1
			host, order = p.left, p.ln
		end
	end

	local r = 7
	local wrap, box = panel(host, order, pal.group, r)
	stack(box, 0)

	local head = mk("Frame", {
		parent = box,
		BackgroundColor3 = pal.panel,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 26),
		LayoutOrder = 1,
	})
	corner(head, r - 2)
	mk("Frame", {
		parent = head,
		BackgroundColor3 = pal.panel,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 8),
		Position = UDim2.new(0, 0, 1, -8),
	})
	text({
		parent = head,
		Text = name or "section",
		TextColor3 = pal.txt,
		Size = UDim2.new(1, -20, 1, 0),
		Position = UDim2.new(0, 10, 0, -3),
		ZIndex = 2,
	})
	divider(head, 24, pal.line).ZIndex = 3

	local hold = mk("Frame", {
		parent = box,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 2,
	})
	inset(hold, 10, 9, 10, 10)

	local body = mk("Frame", {
		parent = hold,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
	})
	stack(body, 7)

	return setmetatable({ win = self.win, tab = self, body = body, frame = wrap, n = 0 }, grp)
end

local win = {}
win.__index = win

local nav_top, nav_bottom, item_h, item_gap, nav_pad, page_pad = 46, 40, 30, 2, 8, 12

function win:reg_popup(fn, alive, sticky)
	table.insert(self.popups, { fn = fn, alive = alive, sticky = sticky })
end

function win:sync_scrim()
	local any = false
	for _, p in self.popups do
		if p.alive and p.alive() then
			any = true
			break
		end
	end
	self.scrim.Visible = any
end

function win:close_popups(all)
	for _, p in self.popups do
		if all or not p.sticky then
			p.fn()
		end
	end
	self:sync_scrim()
end

function win:place(pop, anchor, w, h, align)
	local vp = self.layer.AbsoluteSize
	local o = self.layer.AbsolutePosition
	local a, s = anchor.AbsolutePosition - o, anchor.AbsoluteSize
	local x = align == "right" and (a.X + s.X - w) or a.X
	local y = a.Y + s.Y + 4
	if y + h > vp.Y - 6 then
		y = a.Y - h - 4
	end
	pop.Position = UDim2.fromOffset(
		math.clamp(x, 6, math.max(vp.X - w - 6, 6)),
		math.clamp(y, 6, math.max(vp.Y - h - 6, 6))
	)
end

function win:hk_register(e)
	table.insert(self.hks, e)
	return e
end

function win:_anchor(flag, hull, x, y)
	hull.Position = UDim2.fromOffset(x, y)
	if not flag then
		return
	end
	self.items[flag .. ".x"] = {
		kind = "number",
		get = function()
			return hull.Position.X.Offset
		end,
		set = function(v)
			hull.Position = UDim2.fromOffset(tonumber(v) or x, hull.Position.Y.Offset)
		end,
	}
	self.items[flag .. ".y"] = {
		kind = "number",
		get = function()
			return hull.Position.Y.Offset
		end,
		set = function(v)
			hull.Position = UDim2.fromOffset(hull.Position.X.Offset, tonumber(v) or y)
		end,
	}
end

function win:watermark(cfg)
	cfg = cfg or {}
	local hull, box = plate(self.hud, Enum.AutomaticSize.X, 0, 32)
	self:_anchor(cfg.flag or "hud.mark", hull, cfg.x or 18, cfg.y or 18)
	box.Active = self.shown
	line(box, 11)
	inset(box, 13, 0)

	local order = 0

	local function slot()
		order = order + 1
		return order
	end

	text({
		parent = box,
		Text = cfg.title or "shitaro.lol",
		TextSize = 14,
		TextColor3 = pal.sel,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, 17),
		LayoutOrder = slot(),
	})

	local function bar()
		mk("Frame", {
			parent = box,
			BackgroundColor3 = pal.line,
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(1, 17),
			LayoutOrder = slot(),
		})
	end

	local function chip(id)
		local c = mk("Frame", {
			parent = box,
			BackgroundTransparency = 1,
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.new(0, 0, 1, 0),
			LayoutOrder = slot(),
		})
		line(c, 6)
		image({
			parent = c,
			Image = asset(id),
			Size = UDim2.fromOffset(14, 14),
			ImageColor3 = pal.dim,
			LayoutOrder = 1,
		})
		return text({
			parent = c,
			Text = "0",
			TextSize = 14,
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.fromOffset(0, 17),
			LayoutOrder = 2,
		})
	end

	bar()
	local net = chip(ico.wifi)
	bar()
	local rate = chip(ico.gauge)
	bar()
	local ram = chip(ico.ram)
	bar()
	local crowd = chip(ico.players)
	bar()
	local clock = chip(ico.clock)

	local fx = fader(hull)
	local on, vis, frames, acc, tick, fps = true, true, 0, 0, 0, 0

	local function refresh()
		local ok, v = pcall(function()
			return stats.Network.ServerStatsItem["Data Ping"]:GetValue()
		end)
		net.Text = (ok and math.floor(v + 0.5) or 0) .. "ms"
		rate.Text = fps
		local good, mb = pcall(function()
			return stats:GetTotalMemoryUsageMb()
		end)
		ram.Text = (good and math.floor(mb + 0.5) or 0) .. "mb"
		crowd.Text = #players:GetPlayers() .. "/" .. players.MaxPlayers
		clock.Text = os.date("%H:%M:%S")
	end

	hook(runs.RenderStepped, function(dt)
		if not vis then
			return
		end
		frames, acc, tick = frames + 1, acc + dt, tick + dt
		if acc >= 0.5 then
			fps = math.floor(frames / acc + 0.5)
			frames, acc = 0, 0
		end
		if tick < 0.25 then
			return
		end
		tick = 0
		refresh()
	end)

	local function apply()
		if on == vis then
			return
		end
		vis = on
		if on then
			hull.Visible = true
			fx(1, true)
			fx(0)
			refresh()
		else
			fx(1)
			task.delay(0.14, function()
				if not vis then
					hull.Visible = false
				end
			end)
		end
	end

	table.insert(self.plates, box)
	grip(box, hull, function()
		return self.shown
	end)
	refresh()

	return {
		frame = hull,
		toggle = function(_, state)
			on = state ~= false
			apply()
		end,
	}
end

function win:keylist(cfg)
	cfg = cfg or {}
	local floor = cfg.width or 186
	local hull, box = plate(self.hud, Enum.AutomaticSize.Y, floor, 0, pal.group)
	self:_anchor(cfg.flag or "hud.keys", hull, cfg.x or 18, cfg.y or 58)
	box.Active = self.shown
	stack(box, 0)

	local head = mk("Frame", {
		parent = box,
		BackgroundColor3 = pal.panel,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 25),
		LayoutOrder = 1,
	})
	corner(head, 5)
	mk("Frame", {
		parent = head,
		BackgroundColor3 = pal.panel,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 8),
		Position = UDim2.new(0, 0, 1, -8),
	})
	text({
		parent = head,
		Text = cfg.title or "keybinds",
		TextSize = 12,
		TextColor3 = pal.txt,
		Size = UDim2.new(1, -20, 1, 0),
		Position = UDim2.new(0, 10, 0, -3),
		ZIndex = 2,
	})
	divider(head, 23, pal.line).ZIndex = 3

	local hold = mk("Frame", {
		parent = box,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 2,
	})
	inset(hold, 10, 7, 10, 8)

	local body = mk("Frame", {
		parent = hold,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
	})
	stack(body, 4)

	local fx = fader(hull)
	local rows, on, vis, tick = {}, true, false, 0
	hull.Visible = false
	fx(1, true)

	local function add(e, i)
		local row = mk("Frame", {
			parent = body,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 16),
			LayoutOrder = i,
		})
		local nm = text({
			parent = row,
			Text = "",
			TextSize = 12,
			TextColor3 = pal.dim,
			TextTransparency = 1,
			Size = UDim2.new(1, -64, 1, 0),
		})
		local st = text({
			parent = row,
			Text = "",
			TextSize = 12,
			TextColor3 = pal.txt,
			TextTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Right,
			Size = UDim2.new(0, 60, 1, 0),
			Position = UDim2.new(1, -60, 0, 0),
		})
		if vis then
			to(nm, { TextTransparency = 0 }, fade)
			to(st, { TextTransparency = 0 }, fade)
		end
		return { frame = row, nm = nm, st = st }
	end

	local function kill(r)
		to(r.nm, { TextTransparency = 1 }, fade)
		to(r.st, { TextTransparency = 1 }, fade)
		task.delay(0.14, function()
			r.frame:Destroy()
		end)
	end

	local function shade_rows(a)
		for _, r in rows do
			to(r.nm, { TextTransparency = a }, fade)
			to(r.st, { TextTransparency = a }, fade)
		end
	end

	local function apply()
		local want = on and next(rows) ~= nil
		if want == vis then
			return
		end
		vis = want
		if want then
			hull.Visible = true
			fx(1, true)
			fx(0)
			shade_rows(0)
		else
			fx(1)
			shade_rows(1)
			task.delay(0.14, function()
				if not vis then
					hull.Visible = false
				end
			end)
		end
	end

	local function sweep()
		for i, e in self.hks do
			local live = e.bound()
			local r = rows[e]
			if live and not r then
				rows[e] = add(e, i)
			elseif not live and r then
				rows[e] = nil
				kill(r)
			end
		end
		local want = floor
		for e, r in rows do
			local act, mode, key = e.state()
			r.nm.Text = ("%s <font color=\"#6b6b74\">[%s]</font>"):format(e.name, key_name(key))
			if e.info then
				r.st.Text = e.info(act)
			elseif act then
				r.st.Text = "on"
			elseif mode == "hold" then
				r.st.Text = "hold"
			else
				r.st.Text = "off"
			end
			r.st.TextColor3 = act and pal.sel or pal.dim
			r.nm.TextColor3 = act and pal.txt or pal.dim
			local need = r.nm.TextBounds.X + r.st.TextBounds.X + 32
			if need > want then
				want = need
			end
		end
		if next(rows) and hull.Size.X.Offset ~= want then
			hull.Size = UDim2.fromOffset(math.min(want, 340), 0)
		end
		apply()
	end

	hook(runs.RenderStepped, function(dt)
		tick = tick + dt
		if tick < 0.1 then
			return
		end
		tick = 0
		sweep()
	end)

	table.insert(self.plates, box)
	grip(box, hull, function()
		return self.shown
	end)

	return {
		frame = hull,
		toggle = function(_, state)
			on = state ~= false
			apply()
		end,
	}
end

function win:resize(w, h)
	local vp = self.layer.AbsoluteSize
	w = math.clamp(math.floor(w), 560, math.max(vp.X - 8, 560))
	h = math.clamp(math.floor(h), 380, math.max(vp.Y - 8, 380))
	self.size = Vector2.new(w, h)
	self.root.Size = UDim2.fromOffset(w, h)
	return w, h
end

function win:set_key(k)
	if typeof(k) == "EnumItem" then
		self.key = k.Name
	elseif type(k) == "string" then
		self.key = k
	end
end

function win:tab(cfg)
	if type(cfg) == "string" then
		cfg = { name = cfg }
	end
	local i = #self.tabs + 1

	local page = mk("ScrollingFrame", {
		parent = self.content,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, -page_pad * 2, 1, -nav_top - page_pad * 2),
		Position = UDim2.new(0, page_pad, 0, nav_top + page_pad),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 0,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		Visible = false,
	})
	stack(page, 10)

	local btn = mk("TextButton", {
		parent = self.list,
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		BackgroundColor3 = pal.raised,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, item_h),
		Text = "",
		LayoutOrder = i,
	})
	corner(btn, 4)

	local glyph = image({
		parent = btn,
		Image = cfg.icon and asset(ico[cfg.icon] or cfg.icon) or "",
		Size = UDim2.fromOffset(14, 14),
		Position = UDim2.new(0, 11, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		ImageColor3 = pal.dim,
	})

	local lbl = text({
		parent = btn,
		Text = cfg.name or "tab",
		TextColor3 = pal.dim,
		Size = UDim2.new(1, -33, 1, 0),
		Position = UDim2.new(0, 33, 0, 0),
	})

	local tab = setmetatable({
		win = self,
		name = cfg.name or "tab",
		index = i,
		page = page,
		button = btn,
		label = lbl,
		glyph = glyph,
		order = 0,
	}, tabm)

	self.tabs[i] = tab

	hover(btn, function()
		if self.index == i then
			return
		end
		to(lbl, { TextColor3 = pal.txt })
		to(glyph, { ImageColor3 = pal.txt })
	end, function()
		if self.index == i then
			return
		end
		to(lbl, { TextColor3 = pal.dim })
		to(glyph, { ImageColor3 = pal.dim })
	end)

	btn.MouseButton1Click:Connect(function()
		self:select(i)
	end)

	if not self.index then
		self:select(i)
	end
	return tab
end

function win:select(i)
	local tab = self.tabs[i]
	if not tab or self.index == i then
		return
	end
	self:close_popups(true)
	local prev = self.tabs[self.index]
	if prev then
		prev.page.Visible = false
		to(prev.label, { TextColor3 = pal.dim })
		to(prev.glyph, { ImageColor3 = pal.dim })
	end
	self.index = i
	tab.page.Visible = true
	to(tab.label, { TextColor3 = pal.sel })
	to(tab.glyph, { ImageColor3 = pal.sel })
	to(self.mark, {
		Position = UDim2.new(0, 0, 0, nav_pad + (i - 1) * (item_h + item_gap) + 7),
	}, slidein)
	self.mark.Visible = true
	self.crumb.Text = tab.name
end

function win:toggle(state)
	local vis = state
	if vis == nil then
		vis = not self.shown
	end
	if vis == self.shown then
		return
	end
	self.shown = vis
	unlock(vis)
	if self.modalPin then
		self.modalPin.Modal = vis
	end
	for _, p in self.plates do
		p.Active = vis
	end
	if vis then
		self.root.Visible = true
		self.layer.Visible = true
		self.root.GroupTransparency = 1
		self.rim.Transparency = 1
		to(self.root, { GroupTransparency = 0 }, fade)
		to(self.rim, { Transparency = 0 }, fade)
	else
		self:close_popups(true)
		to(self.root, { GroupTransparency = 1 }, fade)
		to(self.rim, { Transparency = 1 }, fade)
		task.delay(0.14, function()
			if not self.shown then
				self.root.Visible = false
				self.layer.Visible = false
			end
		end)
	end
end

function win:register_extra(key, dump, load)
	if not key or type(dump) ~= "function" or type(load) ~= "function" then
		return
	end
	self.extras[key] = { dump = dump, load = load }
end

function win:serialize()
	local out = {}
	if self.extras then
		for key, extra in pairs(self.extras) do
			local ok, val = pcall(extra.dump)
			if ok and val ~= nil then
				out[#out + 1] = "\1" .. key .. "\2" .. b64enc(tostring(val))
			end
		end
	end
	for flag, item in self.items do
		out[#out + 1] = flag .. "\2" .. item.kind .. "\2" .. encode(item.kind, item.get())
	end
	table.sort(out)
	return b64enc(table.concat(out, "\n"))
end

function win:deserialize(blob)
	local raw = b64dec(blob)
	if not raw or raw == "" then
		return false
	end
	for _, line in split(raw, "\n") do
		if line ~= "" then
			if line:sub(1, 1) == "\1" then
				local key, payload = line:sub(2):match("^([^\2]+)\2(.*)$")
				local extra = key and self.extras and self.extras[key]
				if extra then
					pcall(extra.load, b64dec(payload or ""))
				end
			else
				local p = split(line, "\2")
				local item = self.items[p[1]]
				if item and p[2] == item.kind then
					pcall(item.set, decode(p[2], p[3] or ""))
				end
			end
		end
	end
	return true
end

function win:save(name)
	if not (writefile and makefolder) then
		return false
	end
	if isfolder and not isfolder("shitaro") then
		makefolder("shitaro")
	end
	if isfolder and not isfolder(cfg_dir) then
		makefolder(cfg_dir)
	end
	writefile(cfg_dir .. "/" .. name .. ".cfg", self:serialize())
	return true
end

function win:load(name)
	local path = cfg_dir .. "/" .. name .. ".cfg"
	if not (readfile and isfile and isfile(path)) then
		return false
	end
	return self:deserialize(readfile(path))
end

function win:configs()
	local out = {}
	if not (listfiles and isfolder and isfolder(cfg_dir)) then
		return out
	end
	for _, path in listfiles(cfg_dir) do
		local n = path:match("([^/\\]+)%.cfg$")
		if n then
			out[#out + 1] = n
		end
	end
	table.sort(out)
	return out
end

local NOTIFY_MAX = 6
local NOTIFY_LIFE = 3
local NOTIFY_FADE = 0.35
local NOTIFY_TONES = {
	hi = pal.sel,
	base = pal.txt,
	dim = pal.dim,
	acc = pal.accent,
}

local function rgb2hex(c)
	return string.format("%02X%02X%02X",
		math.floor(c.R * 255 + 0.5),
		math.floor(c.G * 255 + 0.5),
		math.floor(c.B * 255 + 0.5))
end

local function notifyBuildRichText(cfg)
	if type(cfg) == "string" then
		return cfg
	end
	if cfg and cfg.segments then
		local out = {}
		for _, seg in ipairs(cfg.segments) do
			if seg and seg.text then
				local col = seg.color or NOTIFY_TONES[seg.tone or "base"] or pal.txt
				local t = tostring(seg.text):gsub("<", "&lt;"):gsub(">", "&gt;")
				table.insert(out, string.format('<font color="#%s">%s</font>', rgb2hex(col), t))
			end
		end
		return table.concat(out)
	end
	if cfg and cfg.text then return tostring(cfg.text) end
	return ""
end

function win:_ensureNotifyHost()
	if self.notifyHost and self.notifyHost.Parent then return end
	local host = mk("Frame", {
		parent = self.hud,
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 320, 0, 0),
		Position = UDim2.new(1, -18, 0, 18),
		AnchorPoint = Vector2.new(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		ZIndex = 20,
	})
	mk("UIListLayout", {
		parent = host,
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Top,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
	})
	self.notifyHost = host
	self.notifyList = {}
end

function win:notify(cfg)
	self:_ensureNotifyHost()
	local host = self.notifyHost
	if not host or not host.Parent then return end
	local rich = notifyBuildRichText(cfg)
	if rich == "" then return end
	local iconId = (type(cfg) == "table" and cfg.icon) or ico.zap
	local hull, box = plate(host, Enum.AutomaticSize.X, 0, 32, pal.panel, true)
	hull.ZIndex = 21
	line(box, 11)
	inset(box, 13, 0)
	image({
		parent = box,
		Image = asset(iconId),
		Size = UDim2.fromOffset(14, 14),
		ImageColor3 = pal.dim,
		LayoutOrder = 1,
	})
	mk("Frame", {
		parent = box,
		BackgroundColor3 = pal.line,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(1, 17),
		LayoutOrder = 2,
	})
	local lbl = text({
		parent = box,
		Text = rich,
		TextSize = 14,
		TextColor3 = pal.txt,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, 17),
		LayoutOrder = 3,
	})
	local fx = fader(hull)
	fx(1, true)
	fx(0)
	local entry = { hull = hull, lbl = lbl, fx = fx, born = tick(), dying = false }
	table.insert(self.notifyList, entry)
	if #self.notifyList > NOTIFY_MAX then
		local first = table.remove(self.notifyList, 1)
		if first.fx then pcall(first.fx, 1) end
		task.delay(0.16, function() pcall(function() first.hull:Destroy() end) end)
	end
	if not self.notifyTick then
		self.notifyTick = runs.RenderStepped:Connect(function()
			if not self.notifyList or #self.notifyList == 0 then return end
			local now = tick()
			for i = #self.notifyList, 1, -1 do
				local e = self.notifyList[i]
				local age = now - e.born
				if age >= NOTIFY_LIFE and not e.dying then
					e.dying = true
					pcall(e.fx, 1)
					task.delay(0.18, function() pcall(function() e.hull:Destroy() end) end)
				end
				if age >= NOTIFY_LIFE + 0.2 then
					table.remove(self.notifyList, i)
				end
			end
		end)
	end
end

function win:destroy()
	self.dead = true
	unlock(false)
	if self.notifyTick then pcall(function() self.notifyTick:Disconnect() end) self.notifyTick = nil end
	for _, fn in self.popups do
		pcall(fn)
	end
	for _, c in conns do
		pcall(function()
			c:Disconnect()
		end)
	end
	table.clear(conns)
	table.clear(binds)
	table.clear(self.popups)
	table.clear(self.items)
	table.clear(self.tabs)
	capture_fn, bus_down, bus_up, bus_cap = nil, nil, nil, nil
	self.gui:Destroy()
end

local lib = { pal = pal, font = fnt, icons = ico }

function lib.window(cfg)
	cfg = cfg or {}
	local size = cfg.size or Vector2.new(690, 500)
	local side_w = cfg.side or 152

	local self = setmetatable({
		tabs = {},
		items = {},
		extras = {},
		popups = {},
		hks = {},
		plates = {},
		size = size,
		shown = true,
		key = "Insert",
	}, win)

	self.flags = setmetatable({}, {
		__index = function(_, k)
			local it = self.items[k]
			return it and it.get()
		end,
		__newindex = function(_, k, v)
			local it = self.items[k]
			if it then
				it.set(v)
			end
		end,
	})

	self.gui = screen(cfg.name or "shitaro.lol")

	self.hud = mk("Frame", {
		parent = self.gui,
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 1,
	})

	self.root = mk("CanvasGroup", {
		parent = self.gui,
		BackgroundColor3 = pal.bg,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(size.X, size.Y),
		ClipsDescendants = true,
		GroupTransparency = 0,
		ZIndex = 2,
	})
	local inner, outer = ring(self.root, 7)
	inner.ZIndex = 40
	self.rim = outer

	mk("TextButton", {
		parent = self.root,
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Text = "",
		ZIndex = 0,
		AutoButtonColor = false,
	})

	self.scrim = mk("TextButton", {
		parent = self.gui,
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Text = "",
		ZIndex = 4,
		Visible = false,
		AutoButtonColor = false,
	})

	self.modalPin = mk("TextButton", {
		parent = self.gui,
		BackgroundTransparency = 1,
		Text = "",
		Size = UDim2.fromOffset(1, 1),
		Position = UDim2.new(-1, 0, -1, 0),
		AutoButtonColor = false,
		Modal = false,
		Active = false,
	})

	self.layer = mk("Frame", {
		parent = self.gui,
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 6,
	})

	self.scrim.MouseButton1Click:Connect(function()
		self:close_popups(true)
	end)

	local side = mk("Frame", {
		parent = self.root,
		BackgroundColor3 = pal.panel,
		BorderSizePixel = 0,
		Size = UDim2.new(0, side_w, 1, 0),
	})
	corner(side, 7)
	mk("Frame", {
		parent = side,
		BackgroundColor3 = pal.panel,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 8, 1, 0),
		Position = UDim2.new(1, -8, 0, 0),
	})
	local spine = mk("Frame", {
		parent = side,
		BackgroundColor3 = pal.edge,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 3, 1, 0),
		Position = UDim2.new(1, -3, 0, 0),
		ZIndex = 4,
	})
	mk("Frame", {
		parent = spine,
		BackgroundColor3 = pal.line,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 1, 1, 0),
		Position = UDim2.fromOffset(1, 0),
	})

	local brand = mk("Frame", {
		parent = side,
		BackgroundTransparency = 1,
		Active = true,
		Size = UDim2.new(1, 0, 0, nav_top),
	})

	text({
		parent = brand,
		Text = cfg.title or "shitaro.lol",
		TextSize = 15,
		TextColor3 = pal.sel,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.new(1, -14, 1, 0),
	})

	divider(side, nav_top - 2, pal.line, 3)

	local nav = mk("Frame", {
		parent = side,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, -nav_top - nav_bottom),
		Position = UDim2.new(0, 0, 0, nav_top),
	})

	self.mark = mk("Frame", {
		parent = nav,
		BackgroundColor3 = pal.sel,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(2, item_h - 14),
		Position = UDim2.new(0, 0, 0, nav_pad + 7),
		Visible = false,
	})

	self.list = mk("Frame", {
		parent = nav,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -nav_pad * 2, 1, -nav_pad),
		Position = UDim2.fromOffset(nav_pad, nav_pad),
	})
	stack(self.list, item_gap)

	local foot = mk("Frame", {
		parent = side,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, nav_bottom),
		Position = UDim2.new(0, 0, 1, -nav_bottom),
	})
	divider(foot, 1, pal.line, 3)
	local buildTxt = cfg.build or "beta"
	local buildW = math.max(#buildTxt * 7 + 4, 24)
	text({
		parent = foot,
		Text = lp and lp.Name or "user",
		TextSize = 11,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Size = UDim2.new(1, -28 - buildW - 6, 1, 0),
		Position = UDim2.new(0, 14, 0, 0),
	})
	text({
		parent = foot,
		Text = buildTxt,
		TextSize = 11,
		TextColor3 = pal.dim,
		TextXAlignment = Enum.TextXAlignment.Right,
		Size = UDim2.new(0, buildW, 1, 0),
		Position = UDim2.new(1, -14 - buildW, 0, 0),
	})

	self.content = mk("Frame", {
		parent = self.root,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -side_w, 1, 0),
		Position = UDim2.new(0, side_w, 0, 0),
	})

	local head = mk("Frame", {
		parent = self.content,
		BackgroundTransparency = 1,
		Active = true,
		Size = UDim2.new(1, 0, 0, nav_top),
		ZIndex = 2,
	})
	self.crumb = text({
		parent = head,
		Text = "",
		TextColor3 = pal.sel,
		Size = UDim2.new(1, -30, 1, 0),
		Position = UDim2.new(0, 15, 0, 0),
	})
	divider(head, nav_top - 2, pal.line)

	grip(head, self.root)
	grip(brand, self.root)

	local hold = mk("TextButton", {
		parent = self.root,
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(16, 16),
		Position = UDim2.new(1, -17, 1, -17),
		Text = "",
		ZIndex = 45,
		AutoButtonColor = false,
	})

	local pull = image({
		parent = hold,
		Image = asset(ico.resize),
		Size = UDim2.fromOffset(12, 12),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		ImageColor3 = pal.dim,
		Rotation = 90,
	})

	hover(hold, function()
		to(pull, { ImageColor3 = pal.sel })
	end, function()
		to(pull, { ImageColor3 = pal.dim })
	end)

	local sizing, m0, s0, p0, want

	hook(hold.InputBegan, function(i)
		if not pointer(i) then
			return
		end
		sizing, m0, s0, p0, want = true, mouse(), self.size, self.root.Position, nil
	end)

	hook(uis.InputChanged, function(i)
		if sizing and moved(i) then
			want = mouse()
		end
	end)

	hook(runs.RenderStepped, function()
		if not sizing or not want then
			return
		end
		local d = want - m0
		want = nil
		local w, h = self:resize(s0.X + d.X, s0.Y + d.Y)
		self.root.Position = UDim2.new(
			0.5,
			math.floor(p0.X.Offset + (w - s0.X) * 0.5),
			0.5,
			math.floor(p0.Y.Offset + (h - s0.Y) * 0.5)
		)
	end)

	hook(uis.InputEnded, function(i)
		if pointer(i) then
			sizing, want = false, nil
		end
	end)

	self.items["menu.width"] = {
		kind = "number",
		get = function()
			return self.size.X
		end,
		set = function(v)
			self:resize(tonumber(v) or self.size.X, self.size.Y)
		end,
	}
	self.items["menu.height"] = {
		kind = "number",
		get = function()
			return self.size.Y
		end,
		set = function(v)
			self:resize(self.size.X, tonumber(v) or self.size.Y)
		end,
	}

	self:set_key(cfg.key or "Insert")
	unlock(self.shown)

	hook(uis.InputBegan, function(i, busy)
		if busy or capture_fn then
			return
		end
		if i.UserInputType == Enum.UserInputType.Keyboard and i.KeyCode.Name == self.key then
			self:toggle()
		end
	end)

	return self
end

return lib
