---
-- Copyright 2016 by Till Tantau
--
-- This file may be distributed and/or modified under the GNU Public License
--

-- imports
local Sampler = require "grazil.sample.Sampler"
local KTreeSampler = require "grazil.sample.KTreeSampler"
local Digraph = require 'grazil.model.Digraph'
local Vertex  = require 'grazil.model.Vertex'

---
-- A partial k-tree is just a subgraph of a k-tree.
-- This sampler generates a random k-tree using
-- @see KTreeSampler and by later deleting edges.
-- Every edge is deleted with probability p, which is a parameter.
--
local PartialKTreeSampler = {}
PartialKTreeSampler.__index = PartialKTreeSampler

---
-- Constructor
--
function PartialKTreeSampler.new(g, seed)
   local self = Sampler.new(g,seed)
   return setmetatable(self, PartialKTreeSampler)
end

---
-- Replace the stored graph by a randomly sampled partial k-tree.
-- @see addSample
-- 
function PartialKTreeSampler:sample(k, t, p)
   self.g = Digraph.new()
   return self:addSample(k, t, p)
end

---
-- Samples a randomly genertaed partial k-tree.
-- For this, a random k-tree is first generated by @see KTreeSampler with parameter k,t.
-- Afterwards, each edge in the graph is deleted with probability p.
--
function PartialKTreeSampler:addSample(k, t, p)

   -- sample a random k-tree
   local kts = KTreeSampler.new(self.g, self.seed)
   local vertices = kts:addSample(k, t)
   local tmp = kts.g
   
   -- randomly remove some edges
   for _,u in ipairs(vertices) do
      for _,v in ipairs(vertices) do
	 if tmp:arc(u,v) and self.Random:nextRandomNumber() <= p then
	    tmp:disconnect(u,v)
	 end
      end
   end

   -- done
   self.g = tmp
   return vertices
end

-- done
return PartialKTreeSampler