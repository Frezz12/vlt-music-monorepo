<script setup lang="ts">
import * as z from 'zod'
import type { FormSubmitEvent } from '@nuxt/ui'
import type {UsersRecord} from "~/lib/pocketbase-types";
import {usePocketBase} from "~/lib/usePocketbase";

const MAX_FILE_SIZE = 5 * 1024 * 1024 // 2MB
const MIN_DIMENSIONS = { width: 200, height: 200 }
const MAX_DIMENSIONS = { width: 4096, height: 4096 }
const ACCEPTED_IMAGE_TYPES = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp']

const pb = usePocketBase();
const toast = useToast()

const props = defineProps({
  user: Object as PropType<UsersRecord>
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

  if (!props.user?.id) {
    console.error('Не удалось получить ID пользователя');
    return;
  }

  try {
    const formData = new FormData();

    formData.append('avatar', state.avatar);

    const updatedUser = await pb.collection('users').update(
      props.user.id,
      formData
    );

    console.log('✅ Аватарка успешно обновлена!', updatedUser);
    location.reload();
  } catch (error: any) {
    console.error('❌ Ошибка загрузки:', error);
    const toast = useToast();
    toast.add({
      title: 'Ошибка',
      description: error.message || 'Не удалось загрузить аватарку',
      icon: 'i-heroicons-exclamation-circle',
    });
  }
  }
</script>

<template>
  <UForm :schema="schema" :state="state" class="space-y-4 w-64" @submit="onSubmit">
    <UFormField name="avatar" label="Аватар" description="JPG, GIF или PNG. не больше 5МБ.">
      <UFileUpload v-slot="{ open, removeFile }" v-model="state.avatar" accept="image/*">
        <div class="flex flex-wrap items-center gap-3">
          <UAvatar
            size="lg"
            :src="state.avatar ? createObjectUrl(state.avatar) : undefined"
            icon="i-lucide-image"
          />

          <UButton
            :label="props.user?.avatar ? 'Загрузить Аватарку' : 'Обновить Аватарку'"
            color="neutral"
            variant="outline"
            @click="open()"
          />
        </div>

        <p v-if="state.avatar" class="text-xs text-muted mt-1.5">
          {{ state.avatar.name }}

          <UButton
            label="Отмена"
            color="error"
            variant="link"
            size="xs"
            class="p-0"
            @click="removeFile()"
          />
        </p>
      </UFileUpload>
    </UFormField>

    <UButton type="submit" label="Сохранить" color="neutral" />
  </UForm>
</template>
