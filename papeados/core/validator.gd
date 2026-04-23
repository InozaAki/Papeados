extends Node
class_name Validator

'''
Clase de utilidad para validar condiciones comunes en el código, 
como verificar autoridad de servidor, existencia de nodos, etc.

Args:
	node (Node): El nodo desde el cual se realiza la validación, utilizado para acceder a su MultiplayerAPI y mostrar mensajes de error contextuales.

Returns:
	bool: True si el nodo es el servidor; false si es un cliente.
'''
static func ensure_server(node: Node) -> bool:
	if not node.multiplayer.is_server():
		push_error("[%s] Esta acción solo puede ejecutarse en el servidor." % node.name)
		return false
	return true
