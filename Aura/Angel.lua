return {
    Name = "Angel",
    Rig = "R6",
    Animate = function(handler, data)
        local runService = handler and handler.RunService
        if not runService or not runService.Stepped then return nil end

        local beams, seen = {}, {}
        local function collect(inst)
            if not inst or seen[inst] then return end
            seen[inst] = true
            if inst:IsA("Beam") and inst.Attachment1 then
                beams[#beams + 1] = inst
            end
        end
        for _, root in ipairs(data.Parts or {}) do
            collect(root)
            local ok, descendants = pcall(function() return root:GetDescendants() end)
            if ok and descendants then
                for _, descendant in ipairs(descendants) do collect(descendant) end
            end
        end

        local speed, maxAngle = 5, math.rad(20)
        local entries = {}
        for index, beam in ipairs(beams) do
            local attach = beam.Attachment1
            entries[#entries + 1] = {
                Attachment = attach,
                Original   = attach.CFrame,
                Sign       = (index % 2 == 0) and -1 or 1,
            }
        end
        if #entries == 0 then return nil end

        local connection = runService.Stepped:Connect(function(now)
            for _, entry in ipairs(entries) do
                local attach = entry.Attachment
                if attach and attach.Parent then
                    local angle = math.sin(now * speed) * maxAngle * entry.Sign
                    pcall(function()
                        attach.CFrame = entry.Original *
                            CFrame.fromAxisAngle(entry.Original.LookVector, angle)
                    end)
                end
            end
        end)

        return function()
            pcall(function() connection:Disconnect() end)
        end
    end,
    Parts = {
        ["UpperTorso"] = {
            {
                ClassName = "Attachment",
                Properties = {
                    CFrame = CFrame.new(0, 4.25, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
                    Visible = false,
                },
                Children = {
                    {
                        ClassName = "ParticleEmitter",
                        Properties = {
                            Acceleration = Vector3.new(0, -6, 0),
                            EmissionDirection = Enum.NormalId.Front,
                            FlipbookStartRandom = false,
                            Lifetime = NumberRange.new(1, 2),
                            LightEmission = 1,
                            LightInfluence = 1,
                            LockedToPart = true,
                            Rate = 50,
                            RotSpeed = NumberRange.new(-100, 100),
                            Rotation = NumberRange.new(-360, 360),
                            Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.5, 0.300000012), NumberSequenceKeypoint.new(1, 0.5, 0.300000012)}),
                            Speed = NumberRange.new(2.5, 2.5),
                            SpreadAngle = Vector2.new(0, 360),
                            Texture = "http://www.roblox.com/asset/?id=7511321694",
                            Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.100000001, 1), NumberSequenceKeypoint.new(0.300000012, 0), NumberSequenceKeypoint.new(0.800000012, 0), NumberSequenceKeypoint.new(1, 1)}),
                            WindAffectsDrag = false,
                        },
                    },
                    {
                        ClassName = "ParticleEmitter",
                        Name = "ParticleEmitter_2",
                        Properties = {
                            Acceleration = Vector3.new(0, -6, 0),
                            EmissionDirection = Enum.NormalId.Front,
                            FlipbookStartRandom = false,
                            Lifetime = NumberRange.new(1, 2),
                            LightEmission = 1,
                            LightInfluence = 1,
                            LockedToPart = true,
                            Rate = 100,
                            RotSpeed = NumberRange.new(-100, 100),
                            Rotation = NumberRange.new(-360, 360),
                            Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.5, 0.300000012), NumberSequenceKeypoint.new(1, 0.5, 0.300000012)}),
                            Speed = NumberRange.new(2.5, 2.5),
                            SpreadAngle = Vector2.new(0, 360),
                            Texture = "rbxassetid://1084976679",
                            Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.200000003, 0), NumberSequenceKeypoint.new(0.800000012, 0), NumberSequenceKeypoint.new(1, 1)}),
                            WindAffectsDrag = false,
                        },
                    },
                },
            },
            {
                ClassName = "Attachment",
                Name = "Attachment_2",
                Properties = {
                    CFrame = CFrame.new(0, 0.75, 0.5, 1, 0, 0, 0, 1, 0, 0, 0, 1),
                    Visible = false,
                },
                Children = {
                    {
                        ClassName = "Beam",
                        Properties = {
                            Attachment0 = "@Attachment_2",
                            Attachment1 = "@Attachment_3",
                            CurveSize0 = 2,
                            CurveSize1 = 2,
                            FaceCamera = false,
                            LightEmission = 1,
                            LightInfluence = 1,
                            Texture = "rbxassetid://9544400688",
                            TextureSpeed = 0,
                            Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 0)}),
                            Width0 = 4,
                            Width1 = 6,
                        },
                    },
                    {
                        ClassName = "Beam",
                        Name = "Beam_2",
                        Properties = {
                            Attachment0 = "@Attachment_2",
                            Attachment1 = "@Attachment_4",
                            CurveSize0 = -2,
                            CurveSize1 = -2,
                            FaceCamera = false,
                            LightEmission = 1,
                            LightInfluence = 1,
                            Texture = "rbxassetid://9544400688",
                            TextureSpeed = 0,
                            Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 0)}),
                            Width0 = 4,
                            Width1 = 6,
                        },
                    },
                },
            },
            {
                ClassName = "Attachment",
                Name = "Attachment_3",
                Properties = {
                    CFrame = CFrame.new(-5.25, 0, 2, 0.866025388, 0, 0.5, 0, 1, 0, -0.5, 0, 0.866025388),
                    Visible = false,
                },
            },
            {
                ClassName = "Attachment",
                Name = "Attachment_4",
                Properties = {
                    CFrame = CFrame.new(5.25, 0, 2, 0.866025388, 0, -0.5, 0, 1, 0, 0.5, 0, 0.866025388),
                    Visible = false,
                },
            },
        },
    },
}