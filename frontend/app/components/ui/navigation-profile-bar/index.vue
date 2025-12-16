<script setup lang="ts">
import type { NavigationMenuItem } from "@nuxt/ui";

const items = ref<NavigationMenuItem[][]>([
  [
    {
      label: "Панель артиста",
      type: "label",
    },
    {
      label: "Профиль",
      icon: "solar:user-broken",
      to: "/profile",
      defaultOpen: true,
      children: [
        {
          label: "Мои релизы",
          description: "Fully styled and customizable components for Nuxt.",
          icon: "solar:clipboard-check-broken",
          to: "/profile/realese",
        },
        {
          label: "Уведомление",
          description: "Fully styled and customizable components for Nuxt.",
          icon: "solar:bell-bing-broken",
          to: "/profile/notification",
        },
        {
          label: "Настройки",
          description:
            "Learn how to install and configure Nuxt UI in your application.",
          icon: "solar:settings-minimalistic-broken",
          to: "/profile/settings",
        },
      ],
    },
    {
      label: "Дистрибуция",
      icon: "solar:archive-down-minimlistic-broken",
      children: [
        {
          label: "Создать релиз",
          icon: "solar:upload-broken",
          description: "Define shortcuts for your application.",
          to: "/distribution/load-realese",
        },
        {
          label: "Черновики",
          icon: "solar:archive-broken",
          description: "Display a modal/slideover within your application.",
          to: "/distribution/drafts/",
        },
      ],
    },
    {
      label: "Статистика",
      icon: "solar:diagram-up-broken",
      children: [
        {
          label: "Аналитика",
          icon: "solar:pie-chart-2-broken",
          description: "Define shortcuts for your application.",
          to: "/docs/composables/define-shortcuts",
        },
        {
          label: "Финансы",
          icon: "solar:dollar-minimalistic-broken",
          description: "Display a modal/slideover within your application.",
          to: "/docs/composables/use-overlay",
        },
        {
          label: "Линки",
          icon: "solar:link-square-broken",
          description: "Display a modal/slideover within your application.",
          to: "/docs/composables/use-overlay",
        },
      ],
    },
    {
      label: "Финансы",
      icon: "solar:hand-money-broken",
      children: [
        {
          label: "Баланс",
          icon: "solar:ruble-broken",
          description: "Use NuxtLink with superpowers.",
          to: "/docs/components/link",
        },
        {
          label: "Бонусный бананс",
          icon: "solar:wad-of-money-broken",
          description: "Display a modal within your application.",
          to: "/docs/components/modal",
        },
      ],
    },
    {
      label: "Поддержка",
      icon: "solar:question-square-broken",
      children: [
        {
          label: "Запросы",
          icon: "solar:ticket-broken",
          description: "Use NuxtLink with superpowers.",
          to: "/docs/components/link",
        },
        {
          label: "FAQ",
          icon: "solar:bill-list-broken",
          description: "Display a modal within your application.",
          to: "/docs/components/modal",
        },
      ],
    },
  ],
]);
</script>

<template>
  <div class="h-[calc(100vh-130px)]">
    <UNavigationMenu
      orientation="vertical"
      :items="items"
      class="data-[orientation=vertical]:w-48 flex"
      highlightColor="primary"
    />
  </div>
</template>
