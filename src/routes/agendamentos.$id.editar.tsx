import { createFileRoute, Link } from "@tanstack/react-router";
import { FormularioAgendamento } from "@/components/FormularioAgendamento";
import { Banner, Tela, TopAppBar } from "@/components/m3";
import { obterAgendamento } from "@/lib/mock";

export const Route = createFileRoute("/agendamentos/$id/editar")({
  head: () => ({
    meta: [
      { title: "Editar agendamento — Agenda de Grãos" },
      {
        name: "description",
        content: "Altere os dados de um agendamento de carregamento ou descarregamento de grãos.",
      },
      { property: "og:title", content: "Editar agendamento — Agenda de Grãos" },
      {
        property: "og:description",
        content: "Edite título, data, grão, caminhão, horário e observação do agendamento.",
      },
    ],
  }),
  component: Editar,
});

function Editar() {
  const { id } = Route.useParams();
  const item = obterAgendamento(id);

  return (
    <Tela>
      <TopAppBar titulo="Editar agendamento" voltarPara={{ to: "/agendamentos/$id", params: { id } }} />
      <main className="flex-1">
        {item ? (
          <FormularioAgendamento inicial={item} />
        ) : (
          <div className="flex flex-col gap-4 p-4">
            <Banner tipo="erro">Este agendamento não foi encontrado.</Banner>
            <Link
              to="/agendamentos"
              className="flex h-12 items-center justify-center rounded-full border border-outline text-label-large text-primary"
            >
              Voltar para a lista
            </Link>
          </div>
        )}
      </main>
    </Tela>
  );
}
