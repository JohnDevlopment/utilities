# treeNodes
A Tcl extension created with the Tcl stubs library, version 8.6. It adds a new type of Tcl value I call a Node.

The command defines a namespace called `TreeNodeExtension` and exports a command, `node`. The following subcommands are supported:

* __node new__ _name ?parent?_
  * Returns a newly created with named _name_ and, optionally, sets the node's parent to _parent_.
* __node name__ _node ?string?_
  * If only _node_ is passed, returns the name of the node _node_; else it sets the node's name to _string_.
