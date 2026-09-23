/* ---------------------------------------------------------------------------
 * estop.s — arrêt d'urgence par interruption externe (CEG 3536, laboratoire 1)
 *
 * Routines exportées : estop_init (À FAIRE), EXTI2_IRQHandler (À COMPLÉTER)
 * Variable (.bss)     : estop_flag
 *
 * Règle des interruptions (section 4.1) : l'ISR est courte. Exception exigée
 * pour E-Stop : l'ISR met d'abord les sorties en état sûr (verte et bleue
 * éteintes, rouge allumée), positionne estop_flag, efface la requête EXTI et
 * se termine. Le changement complet d'état vers ARRÊT_URGENCE est fait par
 * fsm_step dans la boucle principale.
 *
 * Particularité STM32L5 (RM0438, section 16) : les registres de sélection de
 * port EXTICR sont dans EXTI (EXTI_EXTICR1, offset 0x60), et non dans SYSCFG
 * comme sur les STM32F4/L4. La requête se lit et s'efface dans EXTI_RPR1
 * (front montant) et EXTI_FPR1 (front descendant), par écriture de 1.
 * ------------------------------------------------------------------------- */
#include "registres.inc"

    .syntax unified
    .cpu    cortex-m33
    .thumb

    .bss
    .align  2
    .global estop_flag
estop_flag:     .space  4           /* 1 = E-Stop reçu, à consommer par fsm_step */

    .text
    .align  2

/* void estop_init(void)
 * Configure PB2 comme source de l'interruption EXTI2, priorité la plus élevée.
 *
 * À FAIRE (E4) :
 *   1. EXTI_EXTICR1 : champ EXTI2 (bits 18:16) = EXTICR_PORT_B (0x01).
 *      (lire, effacer le champ avec bic, insérer avec orr, écrire)
 *   2. Choisir le front qui correspond à l'APPUI selon BTN_ESTOP_ACTIF_HAUT :
 *      actif haut -> EXTI_RTSR1 |= EXTI_LIGNE2 ; actif bas -> EXTI_FTSR1 |= EXTI_LIGNE2.
 *      Effacer l'autre front. Effacer toute requête en attente (RPR1 / FPR1).
 *   3. EXTI_IMR1 |= EXTI_LIGNE2 (démasquer la ligne 2).
 *   4. NVIC : octet de priorité NVIC_IPR_BASE + EXTI2_IRQn = NVIC_PRIO_MAX (strb),
 *      puis NVIC_ISER0 = (1 << EXTI2_IRQn) pour activer l'interruption.
 *   (RCC_APB2ENR.SYSCFGEN n'est pas nécessaire pour EXTICR sur la L5.)
 * Registres modifiés : r0-r3 (routine feuille).                             */
    .global estop_init
    .type   estop_init, %function
estop_init:
    /* ----- À COMPLÉTER : étapes 1 à 4 ci-dessus ----- */
    
    ldr     r0, =EXTI_BASE
    
    /*Etape 1*/
    /*Mettre l'adresse de EXTI_EXTICR1 dans r1*/
    ldr     r1, [r0, #EXTI_EXTICR1]

    /*clear les bits (18-16) du champ EXTI2*/
    mov     r2, #7
    lsl     r2, r2, #EXTICR1_EXTI2_POS
    bic     r1, r1, r2

    /*Inserer la valeur EXTICR_PORT_B aux bits (18-16) du champ EXTI2*/
    mov     r2, #EXTICR_PORT_B
    lsl     r2, r2, #EXTICR1_EXTI2_POS
    orr     r1, r1, r2
    
    str     r1, [r0, #EXTI_EXTICR1] /*Store la nouvelle  valeure dans EXTI_EXTICR1*/

    /*Etape 2*/
    /*actif haut -> EXTI_RTSR1 |= EXTI_LIGNE2 */
    ldr     r1, #EXTI_LIGNE2
    ldr     r2, [r0, #EXTI_RTSR1]
    orr     r1, r1, r2
    str     r1, [r0, #EXTI_RTSR1]

    /*effaacer front descendant: bic EXTI_FTSR1, EXTI_LIGNE2 */
    ldr     r2, [r0, #EXTI_FTSR1]
    bic     r2, r2, r1
    str     r2, [r0, #EXTI_FTSR1]

    /* Effacer toute requête en attente (RPR1 / FPR1)*/
    str     r1, [r0, #EXTI_RPR1]
    str     r1, [r0, #EXTI_FPR1]
    
    /*Etape 3*/
    /*EXTI_IMR1 |= EXTI_LIGNE2*/
    ldr     r2, [r0, #EXTI_IMR1]
    orr     r2, r2, r1
    str     r2, [r0, #EXTI_IMR1]
    
    /*Etape 4*/

    /*NVIC_IPR_BASE + EXTI2_IRQn = NVIC_PRIO_MAX (strb)*/
    ldr     r0, =NVIC_IPR_BASE
    mov     r1, #NVIC_PRIO_MAX
    strb    r1, [r0, #EXTI2_IRQn]
    
    /*NVIC_ISER0 = (1 << EXTI2_IRQn) pour activer l'interruption.*/
    ldr     r0, =NVIC_ISER0
    mov     r1, #1
    lsl     r1, r1, #EXTI2_IRQn
    str     r1, [r0]

    /*Fin de la partie du code a completer*/
    bx      lr
    .size   estop_init, .-estop_init

/* void EXTI2_IRQHandler(void)   — vecteur d'interruption EXTI ligne 2
 * Remplace le gestionnaire faible (.weak) du fichier de démarrage.
 * Le matériel empile automatiquement r0-r3, r12, lr, pc, xPSR : une ISR
 * feuille peut utiliser r0-r3 sans les sauvegarder et retourne par bx lr.
 *
 * À COMPLÉTER (E4) :
 *   1. état sûr immédiat, par BSRR (pas de lecture-modification-écriture) :
 *        GPIOC_BSRR = 1 << (LED_VERTE_PIN + 16)   (verte éteinte)
 *        GPIOB_BSRR = 1 << (LED_BLEUE_PIN + 16)   (bleue éteinte)
 *        GPIOA_BSRR = 1 << LED_ROUGE_PIN          (rouge allumée)
 *   2. estop_flag = 1
 *   3. effacer la requête EXTI (fourni ci-dessous) et se terminer.
 * Rien d'autre : pas de temporisation, pas de changement d'état ici.       */
    .global EXTI2_IRQHandler
    .type   EXTI2_IRQHandler, %function
EXTI2_IRQHandler:
    /* ----- À COMPLÉTER : étapes 1 et 2 ----- */
    /*Etape 1*/
    /*Etteindre verte : GPIOC_BSRR = 1 << (LED_VERTE_PIN + 16)*/
    ldr     r0, =GPIOC_BASE
    mov     r1, #1
    ldr     r2, #LED_VERTE_PIN
    add     r2, r2, #16
    lsl	    r1, r1, r2
    str     r1, [r0, #GPIO_BSRR]


    /*Etteindre bleue : GPIOB_BSRR = 1 << (LED_BLEUE_PIN + 16)*/
    ldr     r0, =GPIOB_BASE
    mov     r1, #1
    ldr     r2, #LED_BLEUE_PIN
    add     r2, r2, #16
    lsl	    r1, r1, r2
    str     r1, [r0, #GPIO_BSRR]

    /*Allumer rouge : GPIOA_BSRR = 1 << LED_ROUGE_PIN*/
    ldr     r0, =GPIOA_BASE
    mov     r1, #1
    lsl	    r1, r1, #LED_ROUGE_PIN
    str     r1, [r0, #GPIO_BSRR]
    
    /*Etape 2*/
    /*estop_flag = 1*/
    ldr     r0, =estop_flag
    mov     r1, #1
    str     r1, [r0]
    
    /* 3. effacement de la requête (écriture de 1 : w1c) */
    ldr     r0, =EXTI_BASE
    mov     r1, #EXTI_LIGNE2
    str     r1, [r0, #EXTI_RPR1]
    str     r1, [r0, #EXTI_FPR1]
    bx      lr
    .size   EXTI2_IRQHandler, .-EXTI2_IRQHandler
