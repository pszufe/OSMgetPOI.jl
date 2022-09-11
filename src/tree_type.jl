using DataStructures, AbstractTrees
struct Tree
    dat::SortedDict{String, Union{String,Tree}}
    Tree(pairs...) = new(SortedDict(pairs))
end

AbstractTrees.children(t::Tree) = keys(t.dat) .=> values(t.dat)
AbstractTrees.children(::Pair{String,String}) = []
AbstractTrees.children(p::Pair{String,Tree}) = AbstractTrees.children(last(p))
AbstractTrees.nodevalue(t::Tree) = "*:"*join(keys(t.dat),",")
AbstractTrees.nodevalue(p::Pair{String,Tree}) = first(p)=>nodevalue(last(p))
Base.show(io::IO,t::Tree) = print_tree(io, t)

t = Tree("A"=>"B", "C"=>"D", "E"=>Tree("F"=>"G"))
t

t = Tree("A"=>"B", "C"=>"D", "E"=>Tree("F"=>"G", "H"=>"I", "J"=>Tree("K"=>"L","M"=>"N")))
t