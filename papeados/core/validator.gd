extends Node
class_name Validator

static func ensure_server(node: Node) -> bool:
    if not node.is_multiplayer_authority():
        push_error("This action can only be performed on the server.")
        return true
    return false

