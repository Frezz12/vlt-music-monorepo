<script lang="ts" setup>
import ProfileLayout from "@/layouts/profile.vue";
import MyUiButton from "@/components/ui/my-ui-button/index.vue"
import { usePocketBase } from "~/lib/usePocketbase";

const pb = usePocketBase();
const nameDraft = ref<string>('')

const handleCreateDraft = async () => {
    try {
        const draft = await pb.collection('draft').create({
            'author': pb.authStore.record?.id,
            'realeseName': nameDraft.value
        })
        await navigateTo(`/distribution/drafts/update/info/${draft.id}`)
    } catch (err) {
        console.log(err)
    }
}

</script>

<template>
    <ProfileLayout>
        <div class="pl-5">
            <div class="flex w-[600px] lg:w-[1020px] justify-center ">
                <UModal class="">
                    <UButton label="Создать релиз" color="neutral" variant="subtle" />

                    <template #content>
                        <div class=" h-[300px] flex items-center justify-center">
                            <div class="flex flex-col justify-center items-center gap-5">
                                <Icon name="solar:archive-up-broken" size="44" />
                                 <h1 class=" text-3xl font-bold">Создание Черновика</h1>
                                <UFormField class=""  label="Название черновика">
                                    <UInput v-model="nameDraft" size="md" class="h-10 placeholder:text-sm"  />
                                </UFormField>
                                <MyUiButton @click="handleCreateDraft">
                                    <p>Создать релиз</p>
                                </MyUiButton>
                            </div>
                        </div>
                    </template>
                </UModal>
            </div>
        </div>
    </ProfileLayout>
</template>


<style></style>