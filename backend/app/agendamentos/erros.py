class ErroDeAgendamento(Exception):
    """Exceção base para regras de negócio do agendamento."""

    pass


class AgendamentoNaoEncontrado(ErroDeAgendamento):
    """Lançada quando a busca por ID falha."""

    pass


class ConflitoDeAgendamento(ErroDeAgendamento):
    """Lançada na violação da RN01."""

    pass


class AgendamentoBloqueado(ErroDeAgendamento):
    """Lançada na violação da RN03."""

    pass