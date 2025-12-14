<script setup lang="ts">
interface Props {
  modelValue: string | number
  type?: 'text' | 'password' | 'email' | 'number'
  placeholder?: string
  disabled?: boolean
  readonly?: boolean
  autofocus?: boolean
  autocomplete?: string
  inputClass?: string
  wrapperClass?: string
}

const props = withDefaults(defineProps<Props>(), {
  type: 'text',
  placeholder: '',
  disabled: false,
  readonly: false,
  autofocus: false,
  autocomplete: 'off',
  inputClass: '',
  wrapperClass: ''
})

const emit = defineEmits<{
  'update:modelValue': [value: string | number]
  'focus': []
  'blur': []
}>()

const input = ref<HTMLInputElement>()

const handleInput = (e: Event) => {
  const target = e.target as HTMLInputElement
  emit('update:modelValue', target.value)
}

const handleFocus = () => emit('focus')
const handleBlur = () => emit('blur')

defineExpose({
  focus: () => input.value?.focus(),
  blur: () => input.value?.blur()
})
</script>

<template>
  <div
    :class="[
      'border-2 border-[#CCFF00] rounded-2xl transition-colors hover:border-[#99CC00] focus-within:border-[#66FF00]',
      wrapperClass,
      disabled ? 'opacity-50 cursor-not-allowed' : ''
    ]"
  >
    <input
      ref="input"
      :type="type"
      :placeholder="placeholder"
      :disabled="disabled"
      :readonly="readonly"
      :autofocus="autofocus"
      :autocomplete="autocomplete"
      :value="modelValue"
      :class="[
        'px-5 py-3 w-[300px] outline-none bg-transparent placeholder-gray-400',
        inputClass,
        disabled ? 'cursor-not-allowed' : ''
      ]"
      @input="handleInput"
      @focus="handleFocus"
      @blur="handleBlur"
    />
  </div>
</template>
