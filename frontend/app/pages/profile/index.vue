<script setup lang="ts">
import { useAuth, usePocketBase } from "~/lib/usePocketbase";
import ProfileLayout from "@/layouts/profile.vue";
import type { SocialLinksRecord, UsersRecord } from "~/lib/pocketbase-types";
import MyUiButton from "@/components/ui/my-ui-button/index.vue"
import LoadAvatar from "@/components/ui/load-avatar/index.vue"
import type { SelectItem } from '@nuxt/ui'

interface Link {
  id: number
  icon: string
  url: string
}

const auth = useAuth();
const toast = useToast();


const isAuthenticated = ref<boolean>(false);
const open = ref<boolean>(false)

const user = ref<UsersRecord | null>(null)
const user_update = ref<UsersRecord | null>(null)
const user_logo = ref<string>("")

const links = ref<Link[]>([])
const haveLinks = ref<SocialLinksRecord[]>()

const pb = usePocketBase();

const items = ref([
  {
    value: 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/83/Telegram_2019_Logo.svg/1024px-Telegram_2019_Logo.svg.png',
    avatar: {
      src: 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/83/Telegram_2019_Logo.svg/1024px-Telegram_2019_Logo.svg.png',
    }
  },
  {
    value: 'https://static.tildacdn.com/tild3066-3531-4365-b533-626638366232/___2.png',
    avatar: {
      src: 'https://static.tildacdn.com/tild3066-3531-4365-b533-626638366232/___2.png',
    }
  },
  {
    value: 'https://yastatic.net/s3/doc-binary/src/mediaservices/yandex_music_icon_ru_circle.png',
    avatar: {
      src: 'https://yastatic.net/s3/doc-binary/src/mediaservices/yandex_music_icon_ru_circle.png',
    }
  },
] satisfies SelectItem[])

const value = ref(items.value[0]?.value)
const urlValue = ref<string>("")

const avatar = computed(() => items.value.find(item => item.value === value.value)?.avatar)

onMounted(async () => {
  if (auth.isValid.value) {
    console.log(auth.isValid.value);
    isAuthenticated.value = true;
    user.value = await pb.collection("users").getOne(pb.authStore.record?.id!)
    console.log(user.value?.email)
    user_logo.value = pb.files.getURL(user.value!, user.value?.avatar!)
    return;
  }
  isAuthenticated.value = false;
});

const openModal = () => {
  user_update.value = user.value;
  open.value = !open.value;
}

const isCopied = ref(false)

const copyToClipboard = async (textToCopy: string) => {
  const text = textToCopy
  
  if (!text) {
    return
  }
  
  try {
    if (navigator.clipboard && window.isSecureContext) {
      await navigator.clipboard.writeText(text)
      toast.add({
        title: "ID Скопировано!"
      })
    } else {
      copyToClipboardFallback(text)
    }
    
    isCopied.value = true
    setTimeout(() => {
      isCopied.value = false
    }, 2000)
    
  } catch (err) {
    console.error('Ошибка:', err)
  }
}

const copyToClipboardFallback = (text: string) => {
  const textArea = document.createElement('textarea')
  textArea.value = text
  
  textArea.style.position = 'fixed'
  textArea.style.top = '-9999px'
  textArea.style.left = '-9999px'
  textArea.style.opacity = '0'
  
  document.body.appendChild(textArea)
  textArea.focus()
  textArea.select()
  
  try {
    const successful = document.execCommand('copy')
    if (!successful) {
      throw new Error('Не удалось скопировать')
    }
  } finally {
    document.body.removeChild(textArea)
  }
}

onMounted(async () => {
  
  try {
    haveLinks.value = await pb.collection("social_links").getFullList({
      filter: pb.authStore.record?.id ? `user = "${pb.authStore.record?.id}"` : ''
    })

    for (let i = 0; i < haveLinks.value.length; i++) {
      const link: Link = {
        id: links.value.length + 1,
        icon: haveLinks.value[i]?.icon!,
        url: haveLinks.value[i]?.url!,
      };
      links.value.push(link)
    }

    console.log(haveLinks.value)
  } catch (err) {
    console.log(err)
  }
})

const handleSubmit = async () => {
  try {
    const formData = new FormData();

    if (user_update.value?.email && user_update.value?.nikname) {
      formData.append('email', user_update.value.email);
      formData.append('usename', user_update.value.nikname);
    }

    const updatedUser = await pb.collection('users').update(
      user.value?.id!,
      formData
    );
    if (links.value.length >= 1) {
      if (urlValue.value !== "") {
        for (var i = 0; i < links.value.length; i++) {
          for (var g = 0; g < haveLinks.value!.length; g++) {
            for (var y = 0; y < links.value.length; y++) {
              if (links.value[y]?.url === haveLinks.value![g]?.url) {
                console.log("Найден", links.value[y]?.url)
                links.value = links.value.filter(item => item.url !== haveLinks.value![g]?.url);
              }
              console.log("Не найден", links.value[y]?.url)
            }
          }
          const link = {
            "icon": links.value[i]?.icon,
            "url": links.value[i]?.url,
            "user": pb.authStore.record?.id
          }
          try {
            pb.collection('social_links').create(link)
          } catch (err) {
            console.log(err)
          }
        }
      }
    }
    console.log('User успешно обнавленн!', updatedUser);
    location.reload();
  } catch (error) {
    console.log(error);
  }
}

const handleAddLink = () => {
  console.log(urlValue.value)
  if (value.value && urlValue.value) {
    if (links.value.length >= 5) {
      const toast = useToast()
      toast.add({
        title: 'Добавить можно максимум 5 ссылок',
        description: 'There was a problem with your request.',
        icon: 'solar:folder-error-broken'
      })

      return
    }

    const link: Link = {
      id: links.value.length + 1,
      icon: value.value,
      url: urlValue.value
    };
    links.value.push(link)
    console.log(links.value)
    return
  }
  console.log("Pysto")
};

const openLink = (url: string) => {
  window.open(url)
}

const handleDelete = async (url: string) => {
  for (var i = 0; i < haveLinks.value!.length; i++) {
    if (haveLinks.value![i]?.url === url) {
      try {
        const link = await pb.collection('social_links').getFullList(
        {
          filter: pb.authStore.record?.id ? `url = "${haveLinks.value![i]?.url}"` : ''
        }
        )
        await pb.collection('social_links').delete(link[0]!.id)
        links.value = links.value.filter(item => item.url !== haveLinks.value![i]?.url);
        console.log("Удалено")
      } catch (err) {
        console.log(err)
      }
    } else {
      links.value = links.value.filter(item => item.url !== url);
    }
  }
}

const handleLogout = async () => {
  try {
    await auth.logout();
    navigateTo("/", { external: true });
  } catch (error) {
    console.log(error);
  }
};
</script>

<template>
  <ProfileLayout>
    <div class="pl-5">
      <div class="flex w-[600px] lg:w-[1020px] justify-between">
        <div class="flex items-center">
          <NuxtImg width="100" height="100"
            class="rounded-full w-[120px] h-[120px] object-cover border-2
              border-[#CCFF00] light:border-[#CCFF00] hover:shadow-[0_0px_30px_-15px] shadow-[#CCFF00] transition duration-300 ease-in-out"
            :src="user_logo!"  />
          <div class="pl-5 text-3xl light:text-black">
            <div class="flex items-end">
              <p class="">{{ user?.nikname }}</p>
              <div class="pl-3 flex items-center">
                <p class="text-lg opacity-60">ID: </p>
                <p class="pl-1 text-lg opacity-60">{{ user?.id }}</p>
                <Icon @click="copyToClipboard(user!.id)" class="ml-1 cursor-pointer hover:text-[#CCFF00]" name="solar:copy-broken" size="14" />
              </div>
            </div>
            <p class="text-white/60 light:text-black/60 text-xl">{{ user?.email }}</p>
            <div class="">
              <div class="flex flex-row gap-2 pt-1">
                <div v-for="item in haveLinks" class="">
                  <div class="cursor-pointer border border-white/20 p-1 rounded-lg">
                    <div @click="openLink(item.url!)">
                      <NuxtImg width="18" :src="item.icon" />
                    </div>
                  </div>
                </div>
                <h1>TEST DEPLOY!</h1>
              </div>
            </div>
          </div>
        </div>
        <div class="flex items-center justify-end">
          <MyUiButton @click="openModal">
            <div class="flex items-center">
              <p>Редактировать</p>
              <Icon class="ml-2" name="solar:pen-broken" size="16" />
            </div>
          </MyUiButton>
        </div>
      </div>
      <div class="">
        <UModal class="rounded-3xl" close-icon="solar:close-square-broken" v-model:open="open"
          title="Обновление пользователя" :ui="{ footer: 'justify-end' }">
          <template #body>
            <Placeholder class="h-48" />
            <div class="">
              <div class=" pb-5 border-b border-white/20">
                <LoadAvatar :user="user!" />
              </div>
              <div class="flex flex-col gap-3 pt-5 pb-5 border-b border-white/20">
                <div class="w-full">
                  <UFormField label="Email">
                    <UInput :modelValue="user_update!.email" class="w-full" placeholder="Email" />
                  </UFormField>
                </div>
                <div class="w-full">
                  <UFormField label="Username">
                    <UInput v-model="user_update!.nikname" class="w-full" placeholder="Username" />
                  </UFormField>
                </div>
              </div>
              <div class="flex flex-row gap-3 pt-5">
                <div class="w-full flex-col items-end justify-start">
                  <div class="w-full flex items-center pt-2" v-for="value in links">
                    <div class="w-full flex border border-white/20 p-2 rounded-2xl">
                      <NuxtImg class="w-6" :src="value.icon" />
                      <p @click="openLink(value.url)" class="pl-2 hover:text-[#CCFF00] max-w-[400px] cursor-pointer truncate">{{ value.url }}</p>
                    </div>
                    <div class="flex items-center border border-white/20 ml-1 p-2 rounded-2xl">
                      <Icon @click="handleDelete(value.url)" name="solar:trash-bin-2-broken" size="24"
                        class="cursor-pointer hover:text-red-400 text-red-500" />
                    </div>
                  </div>
                </div>
              </div>
              <div class="flex flex-col gap-3 pt-5">
                <div class="w-full flex items-end justify-start">
                  <div class="">
                    <UFormField label="Иконка">
                      <USelect size="lg" v-model="value" :items="items" value-key="value" :avatar="avatar" class="" />
                    </UFormField>
                  </div>
                  <UFormField class="pl-1" label="Ссылка">
                    <UInput v-model="urlValue" size="lg" variant="outline" placeholder="Ссылка" class="w-[270px]" />
                  </UFormField>
                  <div class="flex pl-1">
                    <MyUiButton @click="handleAddLink" class="flex">
                      <p>Добавить</p>
                    </MyUiButton>
                  </div>
                </div>
                <p class="">{{ links.length }} / 5 макс.</p>
              </div>
            </div>
          </template>
          <template #footer="{ close }">
            <MyUiButton @click="handleSubmit">
              <p>Сохранить</p>
            </MyUiButton>
          </template>
        </UModal>
      </div>

    </div>
  </ProfileLayout>
</template>

<style scoped></style>
