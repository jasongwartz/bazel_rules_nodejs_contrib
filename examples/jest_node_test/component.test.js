import { shallowMount } from '@vue/test-utils'
import Component from './component.vue'

describe('Component', () => {
  it('renders a div', () => {
    const wrapper = shallowMount(Component)
    expect(wrapper.contains('div')).toBe(true)
  })

  it('prints correctly', () => {
    const wrapper = shallowMount(Component)
    expect(wrapper.vm.print()).toBe("Hello Vue3")
  })
});