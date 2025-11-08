import mongoose from 'mongoose';

const productSchema = new mongoose.Schema({
  title: String,
  price: String,
  image: String,
  link: String,
  isGood: Boolean
});

export const Product = mongoose.model('Product', productSchema);
