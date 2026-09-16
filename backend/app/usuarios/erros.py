class UsuarioError(Exception):
    """Classe base para erros de usuário."""
    pass


class EmailJaCadastradoError(UsuarioError):
    pass


class CredenciaisInvalidasError(UsuarioError):
    pass