import products from "../../assets/data/shops.json";

export default function ProductList() {
    return (
        <div className="grid gap-3 grid-cols-4">
            {products.map((product) => (
                <div key={product.id} className="flex flex-col gap-2 border-2 " >
                    <img
                        src={product.image}
                        alt={product.name}
                        // className="w-full"
                        loading="lazy"
                    />
                    <div className="p-2 border-t-2">
                        <h6>{product.name}</h6>
                        <p>₹ {product.price}</p>
                        <button onClick={() => { }}>Add to cart</button>
                    </div>
                </div >
            ))
            }
        </div >
    );
}