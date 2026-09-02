import { createFileRoute, Link, useNavigate } from "@tanstack/react-router";
import { useState } from "react";
import { Banner, BotaoPrincipal, Campo, Tela, inputClasses } from "@/components/m3";

export const Route = createFileRoute("/")({
  head: () => ({
    meta: [
      { title: "Entrar — Agenda de Grãos" },
      {
        name: "description",
        content:
          "Acesse a Agenda de Grãos para motoristas de caminhão e organize carregamentos e descarregamentos.",
      },
      { property: "og:title", content: "Entrar — Agenda de Grãos" },
      {
        property: "og:description",
        content: "Login do aplicativo de agendamento de carga e descarga de grãos.",
      },
    ],
  }),
  component: Login,
});

function Login() {
  const navigate = useNavigate();
  const [email, setEmail] = useState("");
  const [senha, setSenha] = useState("");
  const [erro, setErro] = useState("");
  const [carregando, setCarregando] = useState(false);

  function entrar(e: React.FormEvent) {
    e.preventDefault();
    setErro("");
    if (!email.trim() || !senha.trim()) {
      setErro("Informe e-mail e senha para continuar.");
      return;
    }
    setCarregando(true);
    setTimeout(() => {
      setCarregando(false);
      if (senha !== "123456") {
        setErro("E-mail ou senha inválidos. Tente novamente.");
        return;
      }
      navigate({ to: "/agendamentos" });
    }, 900);
  }

  return (
    <Tela>
      <main className="flex flex-1 flex-col justify-center px-6 py-12">
        <div className="mb-10">
          <div className="mb-6 flex size-14 items-center justify-center rounded-xl bg-primary-container text-on-primary-container">
            <svg viewBox="0 0 24 24" className="size-7" fill="none" stroke="currentColor" strokeWidth="1.8">
              <path d="M3 17h2l1-6h9l1 6h5M6 17a2 2 0 104 0 2 2 0 10-4 0M16 17a2 2 0 104 0 2 2 0 10-4 0" strokeLinecap="round" />
            </svg>
          </div>
          <h1 className="text-headline-medium">Agenda de Grãos</h1>
          <p className="mt-2 text-body-medium text-on-surface-variant">
            Entre para ver e criar seus agendamentos de carga e descarga.
          </p>
        </div>

        <form onSubmit={entrar} className="flex flex-col gap-5" noValidate>
          {erro ? <Banner tipo="erro">{erro}</Banner> : null}

          <Campo label="E-mail">
            <input
              type="email"
              inputMode="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="motorista@transporte.com.br"
              className={inputClasses(!!erro)}
            />
          </Campo>

          <Campo label="Senha" apoio="Use 123456 para entrar neste protótipo.">
            <input
              type="password"
              value={senha}
              onChange={(e) => setSenha(e.target.value)}
              placeholder="••••••"
              className={inputClasses(!!erro)}
            />
          </Campo>

          <BotaoPrincipal type="submit" disabled={carregando}>
            {carregando ? "Entrando…" : "Entrar"}
          </BotaoPrincipal>
        </form>

        <p className="mt-8 text-center text-body-medium text-on-surface-variant">
          Não tem conta?{" "}
          <Link to="/cadastro" className="text-label-large text-primary underline">
            Criar cadastro
          </Link>
        </p>
      </main>
    </Tela>
  );
}
