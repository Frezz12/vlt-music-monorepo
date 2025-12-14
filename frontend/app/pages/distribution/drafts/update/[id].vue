<script lang="ts" setup>
import ProfileLayout from "@/layouts/profile.vue";
import * as z from 'zod'
import type { FormSubmitEvent } from '@nuxt/ui'
import type {DraftRecord, UsersRecord} from "~/lib/pocketbase-types";
import {usePocketBase} from "~/lib/usePocketbase";
import { ca } from "zod/v4/locales";

const route = useRoute()

const MAX_FILE_SIZE = 5 * 1024 * 1024 // 2MB
const MIN_DIMENSIONS = { width: 3000, height: 3000 }
const MAX_DIMENSIONS = { width: 3000, height: 3000 }
const ACCEPTED_IMAGE_TYPES = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp']

const pb = usePocketBase();
const toast = useToast()

const draftID = ref<string>(route.params.id as string)
const draft = ref<DraftRecord | null>(null)

onMounted(async () => {
  try {
    draft.value = await pb.collection('draft').getOne(draftID.value)
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
    const toast = useToast();
    toast.add({
      title: 'Ошибка',
      description: error.message || 'Не удалось загрузить обложку',
      icon: 'i-heroicons-exclamation-circle',
    });
  }
  }

const data = reactive({
    urlLogo: undefined as File | undefined,
})

watch(() => state.avatar, () => {
    console.log(state.avatar)
    uploadAvatarToServer(state.avatar!)
})

const handleCreateDraft = async (data: {
    urlLogo: File,
}) => {
    const formData = new FormData()

}

</script>

<template>
    <ProfileLayout>
        <div class="pl-5">
            <div class="flex w-[600px] lg:w-[1020px] justify-center">
                <div class="flex flex-col items-center gap-5">
                    <p class="flex text-4xl">Загрузить релиз</p>
                      <div v-if="!draft?.logo" class="">
                        <UFileUpload
                        v-slot="{ open, removeFile }" v-model="state.avatar" accept="image/*"
                        size="xl"
                        variant="area"
                        label="Загрузите Обложку"
                        description="JPG (3000x3000px)"
                        class="w-[300px] h-[300px]"
                    />
                      </div>
                      <div v-else class="w-[300px] h-[300px]">
                          <NuxtImg  :src="pb.files.getURL(draft, draft.logo)" />
                      </div>
                </div>
            </div>
        </div>
    </ProfileLayout>
</template>


<style></style>