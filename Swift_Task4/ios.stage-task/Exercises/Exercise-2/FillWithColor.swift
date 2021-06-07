import Foundation

final class FillWithColor {
    
    func fillWithColor(_ image: [[Int]], _ row: Int, _ column: Int, _ newColor: Int) -> [[Int]] {
        
        if (image.isEmpty || row < 0 || column < 0 || row >= image.count || column >= image[0].count) {
            return image
        }
        
        for currentColumn in image {
            if currentColumn.count > 51 {
                return image
            }
        }
        
        if (image[row][column] == newColor || newColor > 65536 || image.count < 1)
        {
            return image
        }
        
        var currentImage = image
        fill(&currentImage, row,column, currentImage[row][column], newColor)
        
        return currentImage
    }
}

private func fill(_ currentMutableImage: inout [[Int]], _ row: Int, _ column: Int, _ currentColor: Int, _ newColor: Int)
{
   
    if (row < 0 || row >= currentMutableImage.count || column < 0 || column >= currentMutableImage[row].count || currentMutableImage[row][column] != currentColor || currentMutableImage[row][column] < 0)
    {
        return
    }
    
    currentMutableImage[row][column] = newColor
    fill(&currentMutableImage, row + 1, column, currentColor, newColor)
    fill(&currentMutableImage, row - 1, column, currentColor, newColor)
    fill(&currentMutableImage, row, column - 1, currentColor, newColor)
    fill(&currentMutableImage, row, column + 1, currentColor, newColor)
}
