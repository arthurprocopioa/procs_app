import { onDocumentWritten } from "firebase-functions/v2/firestore";
import * as logger from "firebase-functions/logger";
import { defineSecret } from "firebase-functions/params";
import OpenAI from "openai";

const openAiApiKey = defineSecret("OPENAI_API_KEY");

export const generateAiPlan = onDocumentWritten(
  {
    document: "users/{userId}",
    secrets: [openAiApiKey],
    region: "us-central1",
  },
  async (event) => {
    if (!event.data) return;

    // Dados do documento do usuário
    const data = event.data.after.data();

    // Status deve ser 'processing_onboarding' para disparar
    if (!data || data.status !== "processing_onboarding") {
      return;
    }

    // Normalização dos dados (pode estar na raiz ou dentro de onboardingData)
    // O app parece salvar em 'onboardingData', mas vamos verificar ambos por segurança
    const onboarding = data.onboardingData || data;

    const userId = event.params.userId;
    logger.info(`Iniciando geração de plano INTELIGENTE (V4) para: ${userId}`);

    const openai = new OpenAI({ apiKey: openAiApiKey.value() });

    // --- Construção do Prompt ---
    // Extraindo dados para o prompt
    const userProfile = {
      gender: onboarding.gender || "Não informado",
      age: onboarding.age || "Não informado",
      height: onboarding.height || "Não informado",
      weight: onboarding.currentWeight || "Não informado",
      targetWeight: onboarding.targetWeight || "Não informado",
      objective: onboarding.objective || "Geral",
      experience: onboarding.experienceLevel || "Iniciante",
      mealCount: onboarding.mealCount || 3, // Importante: Qtd de refeições
      dietRestrictions: onboarding.dietRestrictions || [],
      foodDislikes: onboarding.foodDislikes || [],
      supplements: onboarding.selectedSupplements || [],
      trainingLocation: onboarding.equipmentLocation || "Academia",
      trainingDays: onboarding.scheduleTimesPerWeek || 3,
      injuries: onboarding.hasInjury ? onboarding.injuryDetails : "Nenhuma",
    };

    const prompt = `
      ATUE COMO UM NUTRICIONISTA E PERSONAL TRAINER DE ELITE.
      
      DADOS DO CLIENTE:
      ${JSON.stringify(userProfile, null, 2)}

      TAREFA:
      Crie um protocolo completo de transformação física (Treino + Dieta) altamente personalizado.

      DIRETRIZES DA DIETA (CRÍTICO):
      1. O cliente escolheu fazer **${userProfile.mealCount} refeições por dia**. Respeite isso ESTRITAMENTE.
      2. Para CADA refeição, você DEVE fornecer **3 a 4 OPÇÕES (VARIAÇÕES)** diferentes (ex: Opção Proteica, Opção Prática, Opção Econômica).
      3. O cliente tem aversão a: ${userProfile.foodDislikes.join(", ") || "Nenhum"}. NÃO inclua esses alimentos.
      4. Considere as restrições: ${userProfile.dietRestrictions.join(", ") || "Nenhuma"}.
      
      DIRETRIZES DO TREINO:
      1. Frequência: ${userProfile.trainingDays}x por semana.
      2. Local: ${userProfile.trainingLocation}.
      3. Objetivo: ${userProfile.objective}.

      FORMATO DE RESPOSTA (JSON PURO OBRIGATÓRIO):
      Você DEVE responder APENAS com um JSON seguindo EXATAMENTE esta estrutura (sem markdown fora do JSON):

      {
        "trainingPlan": "String longa contendo o plano de treino completo em Markdown (bem formatado com negrito, listas). Divida por dias (Treino A, B...).",
        
        "dietPlanJSON": {
          "status": "pending_approval",
          "meals": [
            {
              "name": "Nome da Refeição (ex: Café da Manhã)",
              "options": [
                {
                  "name": "Nome da Opção (ex: Ovos com Aveia)",
                  "macros": { "calories": 0, "protein": 0, "carbs": 0, "fat": 0 },
                  "items": [
                    { "name": "Alimento X", "portion": "Quantidade (ex: 2 ovos)", "prepMethod": "Modo de preparo curto" }
                  ]
                }
              ]
            }
          ]
        },

        "scientificExplanation": "Explicação curta do plano (max 3 linhas)."
      }
    `;

    try {
      const completion = await openai.chat.completions.create({
        model: "gpt-4o", // Modelo inteligente necessário para JSON complexo
        messages: [
          {
            role: "system",
            content: "Você é uma IA especializada em Nutrição e Ed. Física. Você SEMPRE responde em JSON válido seguindo estritamente o schema solicitado."
          },
          { role: "user", content: prompt }
        ],
        response_format: { type: "json_object" },
      });

      const content = completion.choices[0].message.content;
      if (!content) throw new Error("Resposta vazia da OpenAI");

      const generatedData = JSON.parse(content);

      // Salvar no Firestore
      // Note: Salvamos dietPlanJSON para a nova tela, e dietPlan (string) se gerarmos um resumo markdown (opcional, mas aqui vamos focar no futuro)
      // Para retrocompatibilidade, vou pedir para o app ler dietPlanJSON.

      await event.data.after.ref.update({
        trainingPlan: generatedData.trainingPlan,
        dietPlanJSON: generatedData.dietPlanJSON, // NOVO CAMPO
        scientificExplanation: generatedData.scientificExplanation,
        status: "ready", // App vai ler isso e parar o loading
        updatedAt: new Date().toISOString(),
      });

      logger.info(`Plano V4 gerado com sucesso para: ${userId}`);

    } catch (error) {
      logger.error("Erro fatal na geração IA:", error);
      await event.data.after.ref.update({
        status: "error",
        errorDetails: "Não foi possível gerar o plano. Tente novamente."
      });
    }
  }
);
