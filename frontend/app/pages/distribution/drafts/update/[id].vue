<script lang="ts" setup>
import ProfileLayout from "@/layouts/profile.vue";
import * as z from 'zod'
import type { FormSubmitEvent } from '@nuxt/ui'
import type { DraftRecord, GenresRecord, UsersRecord } from "~/lib/pocketbase-types";
import { usePocketBase } from "~/lib/usePocketbase";
import { CalendarDate } from '@internationalized/date'

const route = useRoute()

const MAX_FILE_SIZE = 5 * 1024 * 1024 // 2MB
const MIN_DIMENSIONS = { width: 3000, height: 3000 }
const MAX_DIMENSIONS = { width: 3000, height: 3000 }
const ACCEPTED_IMAGE_TYPES = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp']

const pb = usePocketBase();

const draftID = ref<string>(route.params.id as string)
const draft = ref<DraftRecord | null>(null)
const draftEdit = ref<DraftRecord | null>(null)

const inputDateRef = useTemplateRef('inputDateRef')
const modelValue = shallowRef(new CalendarDate(2022, 1, 10))
const genre = ref<string[]>([])
const selectGenre = ref<string>('')

const inviteArtist = ref<string[]>([''])

const isOpenModalLogo = ref<boolean>(false)

onMounted(async () => {
  try {
    draft.value = await pb.collection('draft').getOne(draftID.value)
    draftEdit.value = draft.value
    console.log(draft.value)
  } catch (err) {
    console.log(err)
  }
})

const formatBytes = (bytes: number, decimals = 2) => {
  if (bytes === 0) return '0 Bytes'
  const k = 1024
  const dm = decimals < 0 ? 0 : decimals
  const sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB']
  const i = Math.floor(Math.log(bytes) / Math.log(k))
  return Number.parseFloat((bytes / Math.pow(k, i)).toFixed(dm)) + ' ' + sizes[i]
}

const schema = z.object({
  avatar: z
    .instanceof(File, {
      message: 'Пожалуйста, выберите файл изображения.'
    })
    .refine((file) => file.size <= MAX_FILE_SIZE, {
      message: `Изображение слишком большое. Пожалуйста, выберите изображение меньшего размера. ${formatBytes(MAX_FILE_SIZE)}.`
    })
    .refine((file) => ACCEPTED_IMAGE_TYPES.includes(file.type), {
      message: 'Пожалуйста, загрузите корректный файл изображения. (JPEG, PNG, или WebP).'
    })
    .refine(
      (file) =>
        new Promise((resolve) => {
          const reader = new FileReader()
          reader.onload = (e) => {
            const img = new Image()
            img.onload = () => {
              const meetsDimensions =
                img.width >= MIN_DIMENSIONS.width &&
                img.height >= MIN_DIMENSIONS.height &&
                img.width <= MAX_DIMENSIONS.width &&
                img.height <= MAX_DIMENSIONS.height
              resolve(meetsDimensions)
            }
            img.src = e.target?.result as string

          }
          reader.readAsDataURL(file)
        }),
      {
        message: `The image dimensions are invalid. Please upload an image between ${MIN_DIMENSIONS.width}x${MIN_DIMENSIONS.height} and ${MAX_DIMENSIONS.width}x${MAX_DIMENSIONS.height} pixels.`
      }
    )
})

type Schema = z.output<typeof schema>

const state = reactive<Partial<Schema>>({
  avatar: undefined
})

function createObjectUrl(file: File): string {
  return URL.createObjectURL(file)
}

async function onSubmit(event: FormSubmitEvent<Schema>) {
  console.log('Form data:', event.data)

  const avatarFile = state.avatar
  console.log(avatarFile)

  if (!avatarFile) {
    console.error('No avatar file selected')
    return
  }

  // console.log('Avatar file:', avatarFile)
  // console.log('File name:', avatarFile.name)
  // console.log('File size:', avatarFile.size)
  // console.log('File type:', avatarFile.type)

  try {
    await uploadAvatarToServer(avatarFile)
  } catch (error) {
    console.error('Upload failed:', error)
  }
}

async function uploadAvatarToServer(file: File) {
  if (!state.avatar) {
    console.error('Пожалуйста, выберите файл аватарки');
    return;
  }

  try {
    const formData = new FormData();

    formData.append('logo', state.avatar);

    const updatedUser = await pb.collection('draft').update(
      draftID.value,
      formData
    );

    console.log('✅ Обложка успешно обновлена!', updatedUser);
    draft.value = await pb.collection('draft').getOne(draftID.value)
  } catch (error: any) {
    console.error('❌ Ошибка загрузки:', error);
  }
}

const data = reactive({
  urlLogo: undefined as File | undefined,
})

watch(() => state.avatar, () => {
  console.log(state.avatar)
  uploadAvatarToServer(state.avatar!)
})

const openModalLogo = () => {
  isOpenModalLogo.value = !isOpenModalLogo.value
}

const handleCreateDraft = async (data: {
  urlLogo: File,
}) => {
  const formData = new FormData()

}

onMounted(async () => {
  try {
    const genreLoaded = await pb.collection('genres').getFullList()
    for (var i = 0; i < genreLoaded.length; i++) {
      if (genreLoaded[i]) {
        genre.value.push(genreLoaded[i]?.genre!)
      }
    }
  } catch (err) {
    console.log(err)
  }
})

watch(selectGenre, () => {
  console.log(selectGenre.value)
})

const addInviteArtist = () => {

}

watch(inviteArtist, (newVal) => {
  if (newVal && newVal.length > 0 && newVal[newVal.length - 1]?.trim() !== '') {
    inviteArtist.value.push('');
  }
  console.log(inviteArtist.value)
}, { deep: true });

function cleanupArtists() {
  if (!inviteArtist.value) return;

  inviteArtist.value = inviteArtist.value.filter((artist, index) => {
    if (index === inviteArtist.value!.length - 1) return true;
    return artist?.trim() !== '';
  });
}

</script>

<template>
  <ProfileLayout>
    <div class="pl-10">
      <div class="flex w-[600px] lg:w-[1020px] justify-center">
        <div class="flex flex-col items-center gap-5 w-full">
          <p class="flex text-4xl">Загрузить релиз</p>
          <div class="">
            <UModal class="w-[340px] h-[400px] flex justify-center cursor-pointer" :open="isOpenModalLogo">
              <template #content>
                <div class=" flex flex-col justify-center items-center gap-5">
                  <UFileUpload v-slot="{ open, removeFile }" v-model="state.avatar" accept="image/*" size="xl"
                    variant="area" label="Загрузите Обложку" description="JPG (3000x3000px)"
                    class="w-[250px] h-[250px]" />
                  <div class="flex w-[250px]">
                    <UButton @click="openModalLogo" class="w-full justify-center" size="xl" color="neutral"
                      variant="outline">Готово</UButton>
                  </div>
                </div>
              </template>
            </UModal>
          </div>
          <div v-if="draft?.logo" class="w-[300px] h-[300px]">
            <NuxtImg class="rounded-2xl w-full h-full" :src="pb.files.getURL(draft, draft.logo!)" />
          </div>
          <div v-else class="w-[300px] h-[300px] flex items-center justify-center 
                    rounded-xl bg-white/20">
            <Icon class=" opacity-70" size="128" name="solar:box-broken" />
          </div>
          <div class="w-[300px]">
            <UButton class="flex w-full justify-center items-center text-md" @click="openModalLogo"
              label="Загрузить обложку" icon="solar:gallery-download-bold" size="xl" color="neutral"
              variant="outline" />
          </div>
          <div class="flex flex-col gap-5 w-full pt-2">
            <div class="flex justify-between w-full">
              <UFormField class="w-full max-w-[500px]" size="xl" label="Название релиза">
                <UInput placeholder="" class="w-full" />
              </UFormField>
              <UFormField class="w-full max-w-[500px]" size="xl" label="Версия">
                <UInput placeholder="" class="w-full" />
              </UFormField>
            </div>
            <div class="flex justify-between w-full">
              <UFormField class="w-full" size="xl" label="Дата релиза">
                <UInputDate class="w-full max-w-[500px]" ref="inputDateRef" v-model="modelValue">
                  <template #trailing>
                    <UPopover :reference="inputDateRef?.inputsRef[3]?.$el">
                      <UButton color="neutral" variant="link" size="sm" icon="i-lucide-calendar"
                        aria-label="Select a date" class="px-0" />
                      <template #content>
                        <UCalendar v-model="modelValue" class="p-2" />
                      </template>
                    </UPopover>
                  </template>
                </UInputDate>
              </UFormField>
              <UFormField class="w-full max-w-[500px]" size="xl" label="Жанр">
                <USelect v-model="selectGenre" class="w-[500px]" placeholder="Select status" :items="genre" />
              </UFormField>
            </div>
            <div class="flex justify-between w-full">
              <UFormField class="w-full max-w-[500px]" size="xl" label="UPC (опционально)">
                <UInput placeholder="" class="w-full" />
              </UFormField>
              <UFormField class="w-full max-w-[500px]" size="xl" label="Копирайт">
                <UInput placeholder="" class="w-full" />
              </UFormField>
            </div>
            <div class="flex justify-between w-full">
              <UFormField class="w-full" size="xl" label="Основной артист">
                <UInput placeholder="" class="w-full" />
              </UFormField>
            </div>
            <div class="flex flex-col justify-between w-full">
              <UFormField class="w-full" size="xl" label="Приглашенный артисты">
                <div class="w-full pt-2 flex items-center" v-for="(artist, index) in inviteArtist" :key="index">
                  <UInput v-model="inviteArtist[index]" placeholder="" class="w-full" />
                  <UButton class="ml-2" v-if="inviteArtist.length > 1 && index !== inviteArtist.length - 1" icon="solar:trash-bin-2-broken"
                    variant="outline" color="error" @click="inviteArtist.splice(index, 1)" />
                </div>

              </UFormField>
            </div>
            <div class="">

            </div>
          </div>
        </div>
      </div>
    </div>
  </ProfileLayout>
</template>


<style></style>