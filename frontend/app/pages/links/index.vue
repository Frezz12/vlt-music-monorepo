<script lang="ts" setup>
import { useAuth, useAuthenticated } from "~/lib/usePocketbase";

const auth = useAuth();

const handleLogout = async () => {
  console.log("logout");
  await auth.logout();
};

useAuthenticated();
</script>

<template>
  <div class="min-h-[calc(100vh-65px)] flex items-center justify-center bg-black light:bg-white">
    <div class="relative">
      <!-- Основная плашка в стиле VLT -->
      <div class="relative bg-white/10 light:bg-black/10 backdrop-blur-lg border border-white/20 light:border-black/20 rounded-3xl p-16 shadow-2xl">
        
        <!-- Декоративные элементы в фирменных цветах -->
        <div class="absolute -top-6 -left-6 w-4 h-4 bg-[#CCFF00] rounded-full animate-pulse"></div>
        <div class="absolute -top-4 -right-4 w-3 h-3 bg-[#FF9900] rounded-full animate-pulse delay-150"></div>
        <div class="absolute -bottom-4 -left-4 w-3 h-3 bg-[#FF9900] rounded-full animate-pulse delay-300"></div>
        <div class="absolute -bottom-6 -right-6 w-4 h-4 bg-[#CCFF00] rounded-full animate-pulse delay-450"></div>
        
        <!-- Заголовок -->
        <div class="text-center">
          <h1 class="text-7xl font-black text-white light:text-black mb-6 animate-pulse">
            СКОРО...
          </h1>
          
          <p class="text-lg text-white/70 light:text-black/70 mb-8 font-medium">
            Эта страница будет доступна в ближайшее время
          </p>
          
          <!-- Анимированный индикатор загрузки -->
          <div class="flex justify-center mb-10">
            <div class="flex space-x-2">
              <div class="w-3 h-3 bg-[#CCFF00] rounded-full animate-bounce"></div>
              <div class="w-3 h-3 bg-[#FF9900] rounded-full animate-bounce delay-100"></div>
              <div class="w-3 h-3 bg-[#CCFF00] rounded-full animate-bounce delay-200"></div>
            </div>
          </div>
          
          <!-- Кнопка выхода в стиле сайта -->
          <button 
            @click="handleLogout"
            class="bg-[#CCFF00] cursor-pointer text-black hover:bg-[#CCFF00]/90 rounded-full px-8 py-3 text-sm font-medium transition-all duration-300 transform hover:scale-105"
          >
            Выйти
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.delay-100 {
  animation-delay: 100ms;
}

.delay-150 {
  animation-delay: 150ms;
}

.delay-200 {
  animation-delay: 200ms;
}

.delay-300 {
  animation-delay: 300ms;
}

.delay-450 {
  animation-delay: 450ms;
}
</style>
