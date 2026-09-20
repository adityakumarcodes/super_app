import { createContext, useContext, useState, type ReactNode } from 'react'

type CartProduct = {
    id: number
    name: string
    price: number
    image: string
    category: string
}

export type CartItem = CartProduct & {
    quantity: number
    size: string
}

type CartContextValue = {
    items: CartItem[]
    addItem: (product: CartProduct, quantity?: number) => void
    updateQuantity: (id: number, quantity: number) => void
    removeItem: (id: number) => void
}

const CartContext = createContext<CartContextValue | null>(null)

export function CartProvider({ children }: { children: ReactNode }) {
    const [items, setItems] = useState<CartItem[]>([])

    const addItem = (product: CartProduct, quantity = 1) => {
        setItems((currentItems) => {
            const existingItem = currentItems.find((item) => item.id === product.id)
            if (existingItem) {
                return currentItems.map((item) => item.id === product.id
                    ? { ...item, quantity: item.quantity + quantity }
                    : item)
            }
            return [...currentItems, { ...product, size: '1 Kg', quantity }]
        })
    }

    const updateQuantity = (id: number, quantity: number) => {
        setItems((currentItems) => currentItems.map((item) => item.id === id
            ? { ...item, quantity: Math.max(1, quantity) }
            : item))
    }

    const removeItem = (id: number) => {
        setItems((currentItems) => currentItems.filter((item) => item.id !== id))
    }

    return <CartContext.Provider value={{ items, addItem, updateQuantity, removeItem }}>{children}</CartContext.Provider>
}

export function useCart() {
    const context = useContext(CartContext)
    if (!context) throw new Error('useCart must be used within CartProvider')
    return context
}
