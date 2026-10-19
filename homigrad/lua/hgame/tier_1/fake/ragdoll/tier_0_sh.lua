local ENT = oop.Reg("fake_ragdoll",{"lib_event","lib_duplicate"},true)
if not ENT then return INCLUDE_BREAK end

local PLAYER = FindMetaTable("Player")

PLAYER.InFake = function(self)
	if not IsValid(self) then return false end

	-- Only the live ragdoll body. DeathRagdoll / leftover Dummy must not
	-- count: that blocked standing pickup and HUD use after the first death.
	local rag = self.hgFakeRagdoll or self.FakeRagdoll
	if IsValid(rag) and rag ~= self then return true end

	if self.GetNWEntity then
		rag = self:GetNWEntity("FakeRagdoll")
		if IsValid(rag) and rag ~= self then return true end
	end

	return false
end

ragdollManager = ragdollManager or {}
ragdollManager.entities = ragdollManager.entities or {}

function ENT:Initialize()
	ragdollManager.entities[self] = true

	self:OnInit()
end

function ENT:OnRemove()
	ragdollManager.entities[self] = nil
end

ENT:Event_Add("Construct","RagdollEntities",function(class)
	if not ragdollManager.entities then return end

	for ent in pairs(ragdollManager.entities) do
		if not IsValid(ent) then ragdollManager.entities[ent] = nil continue end

		util.tableLink(ent,class[1])
	end
end)

function ENT:Eye()
	local owner = self:GetController()
	if not IsValid(owner) then return self:GetPos(),self:GetAngles() end//UFFFF

	return owner:Eye()
end