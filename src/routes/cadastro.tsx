import { createFileRoute, Link, useNavigate } from "@tanstack/react-router";
import { useState } from "react";
import { Banner, BotaoPrincipal, Campo, Tela, TopAppBar, inputClasses } from "@/components/m3";

export const Route = createFileRoute("/cadastro")({
  head: () => ({
    meta: [
      { title: "Criar cadastro — Agenda de Grãos" },
      {
        name: "description",
        content: "Cadastre-se com nome, e-mail e senha para agendar carregamentos de grãos.",
      },
      { property: "og:title", content: "Criar cadastro — Agenda de Grãos" },
      {
        property: "og:description",
        content: "Cadastro de motorista no aplicativo de agendamento de grãos.",
      },
    ],
  }),
  component: Cadastro,
});

function Cadastro() {
  const navigate = useNavigate();
  const [nome, setNome] = useState("");
  const [email, setEmail] = useState("");
  const [senha, setSenha] = useState("");
  const [erros, setErros] = useState<{ nome?: string; email?: string; senha?: string }>({});
  const [estado, setEstado] = useState<"parado" | "enviando" | "sucesso" | "erro">("parado");

  function enviar(e: React.FormEvent) {
    e.preventDefault();
    const novos: { nome?: string; email?: string; senha?: string } = {};
    if (nome.trim().length < 3) novos.nome = "Informe seu nome completo (mínimo 3 caracteres).";
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email.trim()))
      novos.email = "Informe um e-mail válido, como nome@empresa.com.br.";
    if (senha.length < 6) novos.senha = "A senha deve ter no mínimo 6 caracteres.";
    setErros(novos);
    if (Object.keys(novos).length > 0) {
      setEstado("erro");
      return;
    }
    setEstado("enviando");
    setTimeout(() => {
      setEstado("sucesso");
      setTimeout(() => navigate({ to: "/agendamentos" }), 900);
    }, 900);
  }

  return (
    <Tela>
      <TopAppBar titulo="Criar cadastro" voltarPara={{ to: "/" }} />
      <main className="flex flex-1 flex-col px-6 pb-12 pt-4">
        <form onSubmit={enviar} className="flex flex-col gap-5" noValidate>
          {estado === "erro" ? (
            <Banner tipo="erro">Revise os campos destacados abaixo.</Banner>
          ) : null}
          {estado === "sucesso" ? (
            <Banner tipo="sucesso">Cadastro criado com sucesso! Levando você para a agenda…</Banner>
          ) : null}

          <Campo label="Nome" erro={erros.nome} apoio="Como aparece na sua CNH.">
            <input
              value={nome}
              onChange={(e) => setNome(e.target.value)}
              placeholder="João da Silva"
              className={inputClasses(!!erros.nome)}
            />
          </Campo>

          <Campo label="E-mail" erro={erros.email} apoio="Usado para entrar no aplicativo.">
            <input
              type="email"
              inputMode="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="joao@transporte.com.br"
              className={inputClasses(!!erros.email)}
            />
          </Campo>

          <Campo label="Senha" erro={erros.senha} apoio="Mínimo de 6 caracteres.">
            <input
              type="password"
              value={senha}
              onChange={(e) => setSenha(e.target.value)}
              placeholder="••••••"
              className={inputClasses(!!erros.senha)}
            />
          </Campo>

          <div className="rounded-md bg-surface-container p-4">
            <p className="text-title-medium">Regras do cadastro</p>
            <ul className="mt-2 space-y-1 text-body-medium text-on-surface-variant">
              <li>• Nome com pelo menos 3 caracteres.</li>
              <li>• E-mail válido e único.</li>
              <li>• Senha com pelo menos 6 caracteres.</li>
            </ul>
          </div>

          <BotaoPrincipal type="submit" disabled={estado === "enviando"}>
            {estado === "enviando" ? "Criando conta…" : "Criar conta"}
          </BotaoPrincipal>
        </form>

        <p className="mt-8 text-center text-body-medium text-on-surface-variant">
          Já tem conta?{" "}
          <Link to="/" className="text-label-large text-primary underline">
            Entrar
          </Link>
        </p>
      </main>
    </Tela>
  );
}
